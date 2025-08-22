/**
 * Firebase Functions 로거 설정
 * 로그 레벨과 구조화된 로깅을 제공합니다.
 */

const functions = require('firebase-functions');

// 로그 레벨 정의
const LogLevel = {
  DEBUG: 0,
  INFO: 1,
  WARNING: 2,
  ERROR: 3
};

// 환경별 최소 로그 레벨
const MIN_LOG_LEVEL = process.env.NODE_ENV === 'production' 
  ? LogLevel.INFO 
  : LogLevel.DEBUG;

// 로그 레벨별 이모지
const LOG_EMOJIS = {
  [LogLevel.DEBUG]: '🔍',
  [LogLevel.INFO]: 'ℹ️',
  [LogLevel.WARNING]: '⚠️',
  [LogLevel.ERROR]: '❌'
};

class Logger {
  constructor(tag) {
    this.tag = tag;
  }

  /**
   * 로그 출력
   * @param {number} level - 로그 레벨
   * @param {string} message - 로그 메시지
   * @param {Object} data - 추가 데이터
   */
  _log(level, message, data = null) {
    // 로그 레벨 확인
    if (level < MIN_LOG_LEVEL) return;

    const emoji = LOG_EMOJIS[level] || '';
    const timestamp = new Date().toISOString();
    const prefix = this.tag ? `[${this.tag}] ` : '';

    // 구조화된 로그 객체 생성
    const logObject = {
      severity: this._getSeverity(level),
      timestamp,
      tag: this.tag,
      message: `${emoji} ${prefix}${message}`
    };

    // 추가 데이터가 있으면 포함
    if (data !== null && data !== undefined) {
      // 민감한 데이터 마스킹
      logObject.data = this._maskSensitiveData(data);
    }

    // Functions의 구조화된 로깅 사용
    switch (level) {
      case LogLevel.ERROR:
        functions.logger.error(logObject.message, logObject);
        break;
      case LogLevel.WARNING:
        functions.logger.warn(logObject.message, logObject);
        break;
      case LogLevel.INFO:
        functions.logger.info(logObject.message, logObject);
        break;
      case LogLevel.DEBUG:
      default:
        functions.logger.debug(logObject.message, logObject);
        break;
    }
  }

  /**
   * 로그 레벨을 Cloud Logging severity로 변환
   */
  _getSeverity(level) {
    switch (level) {
      case LogLevel.ERROR: return 'ERROR';
      case LogLevel.WARNING: return 'WARNING';
      case LogLevel.INFO: return 'INFO';
      case LogLevel.DEBUG: 
      default: return 'DEBUG';
    }
  }

  /**
   * 민감한 데이터 마스킹
   */
  _maskSensitiveData(data) {
    if (typeof data === 'string') {
      return data;
    }

    if (typeof data !== 'object' || data === null) {
      return data;
    }

    const masked = Array.isArray(data) ? [] : {};
    
    for (const key in data) {
      if (data.hasOwnProperty(key)) {
        const value = data[key];
        
        // 민감한 필드 마스킹
        if (this._isSensitiveField(key)) {
          if (typeof value === 'string' && value.length > 4) {
            masked[key] = `${value.substring(0, 4)}...${value.substring(value.length - 4)}`;
          } else {
            masked[key] = '***masked***';
          }
        } else if (typeof value === 'object' && value !== null) {
          // 재귀적으로 마스킹
          masked[key] = this._maskSensitiveData(value);
        } else {
          masked[key] = value;
        }
      }
    }

    return masked;
  }

  /**
   * 민감한 필드인지 확인
   */
  _isSensitiveField(fieldName) {
    const sensitiveFields = [
      'password', 'token', 'secret', 'api_key', 'apiKey',
      'auth', 'authorization', 'credit_card', 'creditCard',
      'ssn', 'social_security', 'email', 'phone', 'phoneNumber',
      'uid', 'userId'
    ];
    
    const lowerFieldName = fieldName.toLowerCase();
    return sensitiveFields.some(field => lowerFieldName.includes(field));
  }

  // 로그 레벨별 메서드
  debug(message, data) {
    this._log(LogLevel.DEBUG, message, data);
  }

  info(message, data) {
    this._log(LogLevel.INFO, message, data);
  }

  warning(message, data) {
    this._log(LogLevel.WARNING, message, data);
  }

  error(message, error) {
    const errorData = {
      message: error?.message || String(error),
      stack: error?.stack,
      code: error?.code
    };
    this._log(LogLevel.ERROR, message, errorData);
  }

  // 데이터 마스킹 유틸리티
  maskData(data) {
    if (data === null || data === undefined) return 'null';
    
    if (Array.isArray(data)) {
      return `Array(${data.length} items)`;
    } else if (typeof data === 'object') {
      return `Object(${Object.keys(data).length} keys)`;
    } else if (typeof data === 'string' && data.length > 50) {
      return `${data.substring(0, 20)}...${data.substring(data.length - 10)}`;
    }
    
    return String(data);
  }

  // 민감한 문자열 마스킹
  maskSensitive(value, visibleChars = 4) {
    if (!value || value.length <= visibleChars * 2) return value;
    
    const start = value.substring(0, visibleChars);
    const end = value.substring(value.length - visibleChars);
    return `${start}....${end}`;
  }
}

// 로거 생성 헬퍼
function createLogger(tag) {
  return new Logger(tag);
}

// 기본 로거
const defaultLogger = new Logger('Functions');

module.exports = {
  Logger,
  createLogger,
  defaultLogger,
  LogLevel
};