/**
 * Unified Counter Increment Function
 *
 * Firebase-Centric Architecture v1.0 - Sharded Counter Auto-Aggregation
 * - Firestore Trigger: onDocumentWritten on counters/{counterId}/shards/{shardId}
 * - 32개 샤드 자동 집계
 * - posts/{postId} 문서에 결과 업데이트
 *
 * Features: voting, creation
 *
 * Counter ID 형식:
 * - vote_{postId}: 투표 카운터
 * - interaction_{postId}: 상호작용 카운터 (like, share, etc)
 *
 * 업데이트 필드:
 * - votesA, votesB, totalVotes (voting)
 * - likeCount, shareCount, viewCount, etc (creation)
 * - counterLastUpdated: Timestamp
 */

const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");

exports.incrementCounter = functions.firestore.onDocumentWritten(
  "counters/{counterId}/shards/{shardId}",
  async (event) => {
    const counterId = event.params.counterId;
    const shardId = event.params.shardId;
    const snapshot = event.data.after;

    // 샤드 삭제 시 무시
    if (!snapshot.exists) {
      console.log(`🗑️ Shard deleted: ${counterId}/${shardId}`);
      return null;
    }

    try {
      // counterId 파싱: "vote_postId123" or "interaction_postId456"
      const parts = counterId.split("_");
      if (parts.length < 2) {
        console.error(`❌ Invalid counterId format: ${counterId}`);
        return null;
      }

      const counterType = parts[0];
      const entityId = parts.slice(1).join("_"); // postId에 '_'가 있을 수 있음

      console.log(`📊 Counter update triggered: ${counterType}/${entityId}`);

      // 모든 샤드 읽기 (32개)
      const shardsSnapshot = await admin
        .firestore()
        .collection("counters")
        .doc(counterId)
        .collection("shards")
        .get();

      // 집계 계산
      const totals = {};
      let shardCount = 0;

      shardsSnapshot.forEach((doc) => {
        const data = doc.data();
        Object.keys(data).forEach((key) => {
          if (typeof data[key] === "number" && key !== "lastUpdated") {
            totals[key] = (totals[key] || 0) + data[key];
          }
        });
        shardCount++;
      });

      console.log(
        `📈 Aggregated ${shardCount} shards:`,
        JSON.stringify(totals)
      );

      // posts 문서 업데이트
      const postRef = admin.firestore().collection("posts").doc(entityId);

      await postRef.update({
        ...totals,
        counterLastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(
        `✅ Counter updated: ${counterType}/${entityId}`,
        JSON.stringify(totals)
      );

      return null;
    } catch (error) {
      console.error(`❌ Counter increment failed: ${counterId}`, error);

      // 에러가 발생해도 재시도하지 않음 (idempotent)
      return null;
    }
  }
);
