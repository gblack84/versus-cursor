import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'versus_icon_data.dart';

class VersusIcons {
  /// 현재 사용 중인 아이콘 스타일
  static VersusIconStyle currentStyle = VersusIconStyle.material;
  
  // ===== 네비게이션 아이콘 =====
  static const VersusIconData back = VersusIconData(
    material: Icons.arrow_back,
    sfSymbol: SFSymbols.arrow_left,
    cupertino: CupertinoIcons.back,
  );
  
  static const VersusIconData forward = VersusIconData(
    material: Icons.arrow_forward,
    sfSymbol: SFSymbols.arrow_right,
    cupertino: CupertinoIcons.forward,
  );
  
  static const VersusIconData close = VersusIconData(
    material: Icons.close,
    sfSymbol: SFSymbols.xmark,
    cupertino: CupertinoIcons.clear,
  );
  
  static const VersusIconData menu = VersusIconData(
    material: Icons.menu,
    sfSymbol: SFSymbols.line_horizontal_3,
    cupertino: CupertinoIcons.bars,
  );
  
  // ===== 미디어 아이콘 =====
  static const VersusIconData image = VersusIconData(
    material: Icons.image_outlined,
    sfSymbol: SFSymbols.photo,
    cupertino: CupertinoIcons.photo,
  );
  
  static const VersusIconData video = VersusIconData(
    material: Icons.videocam_outlined,
    sfSymbol: SFSymbols.film_fill,
    cupertino: CupertinoIcons.videocam,
  );
  
  static const VersusIconData camera = VersusIconData(
    material: Icons.camera_alt_outlined,
    sfSymbol: SFSymbols.camera,
    cupertino: CupertinoIcons.camera,
  );
  
  static const VersusIconData gallery = VersusIconData(
    material: Icons.photo_library_outlined,
    sfSymbol: SFSymbols.camera_on_rectangle,
    cupertino: CupertinoIcons.photo_on_rectangle,
  );
  
  // ===== 액션 아이콘 =====
  static const VersusIconData add = VersusIconData(
    material: Icons.add,
    sfSymbol: SFSymbols.plus,
    cupertino: CupertinoIcons.add,
  );
  
  static const VersusIconData edit = VersusIconData(
    material: Icons.edit_outlined,
    sfSymbol: SFSymbols.pencil,
    cupertino: CupertinoIcons.pencil,
  );
  
  static const VersusIconData delete = VersusIconData(
    material: Icons.delete_outline,
    sfSymbol: SFSymbols.trash,
    cupertino: CupertinoIcons.delete,
  );
  
  static const VersusIconData share = VersusIconData(
    material: Icons.share_outlined,
    sfSymbol: SFSymbols.square_arrow_up,
    cupertino: CupertinoIcons.share,
  );
  
  // ===== 상태 아이콘 =====
  static const VersusIconData success = VersusIconData(
    material: Icons.check_circle_outline,
    sfSymbol: SFSymbols.checkmark_circle,
    cupertino: CupertinoIcons.check_mark_circled,
  );
  
  static const VersusIconData error = VersusIconData(
    material: Icons.error_outline,
    sfSymbol: SFSymbols.exclamationmark_circle,
    cupertino: CupertinoIcons.exclamationmark_circle,
  );
  
  static const VersusIconData warning = VersusIconData(
    material: Icons.warning_amber_outlined,
    sfSymbol: SFSymbols.exclamationmark_triangle,
    cupertino: CupertinoIcons.exclamationmark_triangle,
  );
  
  static const VersusIconData info = VersusIconData(
    material: Icons.info_outline,
    sfSymbol: SFSymbols.info_circle,
    cupertino: CupertinoIcons.info_circle,
  );
  
  // ===== 특수 용도 (이모지 대체) =====
  static const VersusIconData target = VersusIconData(
    material: Icons.adjust,
    sfSymbol: null, // SFSymbols.target이 없어서 일단 null
    cupertino: CupertinoIcons.scope,
  );
  
  static const VersusIconData check = VersusIconData(
    material: Icons.check,
    sfSymbol: SFSymbols.checkmark,
    cupertino: CupertinoIcons.check_mark,
  );
  
  static const VersusIconData vote = VersusIconData(
    material: Icons.how_to_vote_outlined,
    sfSymbol: SFSymbols.checkmark_square,
    cupertino: CupertinoIcons.check_mark_circled_solid,
  );
  
  static const VersusIconData notification = VersusIconData(
    material: Icons.notifications_outlined,
    sfSymbol: SFSymbols.bell,
    cupertino: CupertinoIcons.bell,
  );
  
  // ===== 추가 유용한 아이콘들 =====
  static const VersusIconData home = VersusIconData(
    material: Icons.home_outlined,
    sfSymbol: SFSymbols.house,
    cupertino: CupertinoIcons.home,
  );
  
  static const VersusIconData search = VersusIconData(
    material: Icons.search,
    sfSymbol: null, // SF Symbols에 magnifyingglass가 없음
    cupertino: CupertinoIcons.search,
  );
  
  static const VersusIconData profile = VersusIconData(
    material: Icons.person_outline,
    sfSymbol: SFSymbols.person,
    cupertino: CupertinoIcons.person,
  );
  
  static const VersusIconData settings = VersusIconData(
    material: Icons.settings_outlined,
    sfSymbol: SFSymbols.gear,
    cupertino: CupertinoIcons.settings,
  );
  
  static const VersusIconData heart = VersusIconData(
    material: Icons.favorite_outline,
    sfSymbol: SFSymbols.heart,
    cupertino: CupertinoIcons.heart,
  );
  
  static const VersusIconData heartFilled = VersusIconData(
    material: Icons.favorite,
    sfSymbol: SFSymbols.heart_fill,
    cupertino: CupertinoIcons.heart_fill,
  );
  
  // ===== 아이콘 크기 상수 =====
  static const double sizeSmall = 16.0;
  static const double sizeMedium = 24.0;
  static const double sizeLarge = 32.0;
  static const double sizeXLarge = 48.0;
}