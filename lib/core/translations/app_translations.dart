import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          // Common
          'app_name': 'Xsium Chat',
          'cancel': 'Cancel',
          'confirm': 'Confirm',
          'error': 'Error',
          'success': 'Success',

          // Login Screen
          'welcome_message': 'Welcome to Xsium',
          'login_this_device': 'Login on This Device',
          'login_other_device': 'Login on Another Device',
          'qr_login_title': 'QR Code Login',
          'qr_login_instruction':
              'Scan the QR code below with the Xaman app on another device.',
          'login_error': 'Login failed. Please try again.',
          'qr_login_cancel_title': 'Cancel QR Login',
          'qr_login_cancel_message': 'Do you want to cancel the QR login?',
          'continue': 'Continue',
          // Login Errors
          'login_incomplete':
              'Login not completed.\nPlease complete login in Xaman.',
          'xaman_connection_error':
              'Communication with Xaman is not smooth.\nLogin has been cancelled.',
          'xumm_cannot_launch':
              'Cannot launch the Xaman app. Please try again.',
          'qr_code_error': 'An error occurred while generating the QR code.',
          'login_expiry_warning':
              'Login session is about to expire. 15 seconds left.',
          'unknown_error': 'An unknown error occurred.',
          'login_attempt_error': 'An error occurred while attempting login.',
          'login_expired': 'Login session has expired.',
          'login_processing_error':
              'An error occurred during login processing. Please try again.',

          'login_cancelled': 'The login has been cancelled.',
          'invalid_login_request': 'Invalid login request.',
          'user_cancelled_login': 'The user has cancelled the login.',
          'server_error_occurred': 'A server error has occurred.',
          'xumm_not_installed': 'XUMM is not installed',
          'xumm_launch_failed': 'Failed to launch XUMM',
          'null_status_received': 'Null status received from XUMM service',
          'invalid_account_data': 'Invalid account data received',

          'login_data_null': 'Login data is null',
          'invalid_login_data_structure': 'Invalid login data structure',

          // New keys for XummService
          'login_in_progress': 'Login process already in progress',
          'api_credentials_unavailable': 'API credentials not available',
          'unsupported_http_method': 'Unsupported HTTP method',
          'api_request_failed': 'API request failed',
          'api_response_parse_error': 'Failed to parse API response',
          'xumm_login_instruction': 'Xsium Login',
          //log out
          'logout': 'Logout',
          'logout_title': 'Logout',
          'logout_confirm_message': 'Are you sure you want to logout?',
          'logout_error_message':
              'An error occurred during logout. Please try again.',
          'logout_success': 'Successfully logged out',

          // Home Screen
          'home': 'Home',
          'friends': 'Friends',
          'chats': 'Chats',
          'canvas': 'Canvas',
          'invites': 'Invites',
          'exit_title': 'Exit App',
          'exit_message': 'Do you want to exit the app?',
          'session_expired': 'Session expired. Please login again.',
          'logout_error': 'Error occurred during logout.',

          // Settings
          'settings': 'Settings',
          'theme': 'Theme',
          'language': 'Language',
          'dark_mode': 'Dark Mode',
          'light_mode': 'Light Mode',
        },
        'ko_KR': {
          // 공통
          'app_name': 'Xsium 채팅',
          'cancel': '취소',
          'confirm': '확인',
          'error': '오류',
          'success': '성공',
          'qr_login_cancel_title': 'QR 로그인 취소',
          'qr_login_cancel_message': 'QR 로그인을 취소하시겠습니까?',
          'continue': '계속',

          // 로그인 화면
          'welcome_message': 'Xsium에 오신 것을 환영합니다',
          'login_this_device': '이 기기에서 로그인',
          'login_other_device': '다른 기기에서 로그인',
          'qr_login_title': 'QR 코드 로그인',
          'qr_login_instruction': '다른 기기의 Xaman 앱으로 아래 QR 코드를 스캔하세요.',
          'login_error': '로그인에 실패했습니다. 다시 시도해주세요.',
          // 로그인 에러
          'login_incomplete': '로그인이 완료되지 않았습니다.\nXaman에서 로그인을 완료해주세요',
          'xaman_connection_error': 'Xaman과의 통신이 원활하지 않습니다.\n로그인이 취소되었습니다',
          'xumm_cannot_launch': 'Xaman 앱을 실행할 수 없습니다. 다시 시도해주세요.',
          'qr_code_error': 'QR 코드 생성 중 오류가 발생했습니다.',
          'login_expiry_warning': '로그인 시간이 곧 만료됩니다. 15초 남았습니다.',
          'unknown_error': '알 수 없는 오류가 발생했습니다.',
          'login_attempt_error': '로그인 시도 중 오류가 발생했습니다.',
          'login_expired': '로그인 시간이 만료되었습니다.',
          'login_processing_error': '로그인 처리 중 오류가 발생했습니다. 다시 시도해주세요.',

          'login_cancelled': '로그인이 취소되었습니다.',
          'invalid_login_request': '잘못된 로그인 요청입니다.',
          'user_cancelled_login': '사용자가 로그인을 취소했습니다.',
          'server_error_occurred': '서버 오류가 발생했습니다.',
          'xumm_not_installed': 'Xaman이 설치되어 있지 않습니다',
          'xumm_launch_failed': 'Xaman 실행에 실패했습니다',
          'null_status_received': 'Xaman 서비스로부터 null 상태를 받았습니다',
          'invalid_account_data': '잘못된 계정 데이터를 받았습니다',

          'login_data_null': '로그인 데이터가 null입니다',
          'invalid_login_data_structure': '잘못된 로그인 데이터 구조입니다',

          // New keys for XummService
          'login_in_progress': '이미 로그인이 진행 중입니다',
          'api_credentials_unavailable': 'API 인증 정보를 사용할 수 없습니다',
          'unsupported_http_method': '지원하지 않는 HTTP 메소드입니다',
          'api_request_failed': 'API 요청이 실패했습니다',
          'api_response_parse_error': 'API 응답 파싱에 실패했습니다',
          'xumm_login_instruction': 'Xsium 로그인',
          // 로그아웃 관련
          'logout': '로그아웃',
          'logout_title': '로그아웃',
          'logout_confirm_message': '정말 로그아웃 하시겠습니까?',
          'logout_error_message': '로그아웃 중 오류가 발생했습니다. 다시 시도해주세요.',
          'logout_success': '로그아웃되었습니다',

          // 홈 화면
          'home': '홈',
          'friends': '친구',
          'chats': '채팅',
          'canvas': '캔버스',
          'invites': '초대',
          'exit_title': '앱 종료',
          'exit_message': '앱을 종료하시겠습니까?',
          'session_expired': '세션이 만료되었습니다. 다시 로그인해주세요.',
          'logout_error': '로그아웃 중 오류가 발생했습니다.',

          // 설정
          'settings': '설정',
          'theme': '테마',
          'language': '언어',
          'dark_mode': '다크 모드',
          'light_mode': '라이트 모드',
        },
        'ja_JP': {
          // 共通
          'app_name': 'Xsium チャット',
          'cancel': 'キャンセル',
          'confirm': '確認',
          'error': 'エラー',
          'success': '成功',
          'qr_login_cancel_title': 'QRログインのキャンセル',
          'qr_login_cancel_message': 'QRログインをキャンセルしますか？',
          'continue': '続ける',

          // ログイン画面
          'welcome_message': 'Xsiumへようこそ',
          'login_this_device': 'この端末でログイン',
          'login_other_device': '他の端末でログイン',
          'qr_login_title': 'QRコードログイン',
          'qr_login_instruction': '他の端末のXamanアプリで以下のQRコードをスキャンしてください。',
          'login_error': 'ログインに失敗しました。もう一度お試しください。',

          // ログインエラー
          'login_incomplete': 'ログインが完了していません。\nXamanでログインを完了してください。',
          'xaman_connection_error': 'Xamanとの通信が円滑ではありません。\nログインがキャンセルされました。',
          'xumm_cannot_launch': 'Xamanアプリを起動できません。再試行してください。',
          'qr_code_error': 'QRコードの生成中にエラーが発生しました。',
          'login_expiry_warning': 'ログインがまもなく期限切れになります。あと15秒です。',
          'unknown_error': '不明なエラーが発生しました。',
          'login_attempt_error': 'ログイン試行中にエラーが発生しました。',
          'login_expired': 'ログインの有効期限が切れました。',
          'login_processing_error': 'ログイン処理中にエラーが発生しました。もう一度お試しください。',
          'login_cancelled': 'ログインがキャンセルされました。',
          'invalid_login_request': '無効なログイン要求です。',
          'user_cancelled_login': 'ユーザーがログインをキャンセルしました。',
          'server_error_occurred': 'サーバーエラーが発生しました。',
          // New keys for LoginController
          'xumm_not_installed': 'Xamanがインストールされていません',
          'xumm_launch_failed': 'Xamanの起動に失敗しました',
          'null_status_received': 'Xamanサービスからnullの状態を受信しました',
          'invalid_account_data': '無効なアカウントデータを受信しました',

          'login_data_null': 'ログインデータがnullです',
          'invalid_login_data_structure': '無効なログインデータ構造です',

          // New keys for XummService
          'login_in_progress': 'ログイン処理が既に進行中です',
          'api_credentials_unavailable': 'API認証情報が利用できません',
          'unsupported_http_method': '未対応のHTTPメソッドです',
          'api_request_failed': 'APIリクエストが失敗しました',
          'api_response_parse_error': 'APIレスポンスの解析に失敗しました',
          'xumm_login_instruction': 'Xsiumログイン',
          // ログアウト関連
          'logout': 'ログアウト',
          'logout_title': 'ログアウト',
          'logout_confirm_message': 'ログアウトしてもよろしいですか？',
          'logout_error_message': 'ログアウト中にエラーが発生しました。もう一度お試しください。',
          'logout_success': 'ログアウトしました',

          // ホーム画面
          'home': 'ホーム',
          'friends': '友達',
          'chats': 'チャット',
          'canvas': 'キャンバス',
          'invites': '招待',
          'exit_title': 'アプリ終了',
          'exit_message': 'アプリを終了しますか？',
          'session_expired': 'セッションが切れました。再度ログインしてください。',
          'logout_error': 'ログアウト中にエラーが発生しました。',

          // 設定
          'settings': '設定',
          'theme': 'テーマ',
          'language': '言語',
          'dark_mode': 'ダークモード',
          'light_mode': 'ライトモード',
        },
        'es_ES': {
          // Común
          'app_name': 'Chat Xsium',
          'cancel': 'Cancelar',
          'confirm': 'Confirmar',
          'error': 'Error',
          'success': 'Éxito',
// es_ES 섹션에 추가
          'qr_login_cancel_title': 'Cancelar inicio de sesión QR',
          'qr_login_cancel_message': '¿Desea cancelar el inicio de sesión QR?',
          'continue': 'Continuar',
          // Pantalla de inicio de sesión
          'welcome_message': 'Bienvenido a Xsium',
          'login_this_device': 'Iniciar sesión en este dispositivo',
          'login_other_device': 'Iniciar sesión en otro dispositivo',
          'qr_login_title': 'Inicio de sesión con código QR',
          'qr_login_instruction':
              'Escanea el código QR con la aplicación Xaman en otro dispositivo.',
          'login_error':
              'Error al iniciar sesión. Por favor, inténtalo de nuevo.',

          // Errores de inicio de sesión
          'login_incomplete':
              'Inicio de sesión no completado.\nPor favor, complete el inicio de sesión en Xaman.',
          'xaman_connection_error':
              'La comunicación con Xaman no es fluida.\nSe ha cancelado el inicio de sesión.',
          'xumm_cannot_launch':
              'No se puede abrir la aplicación Xaman. Por favor, inténtalo de nuevo.',
          'qr_code_error': 'Se produjo un error al generar el código QR.',
          'login_expiry_warning':
              'La sesión de inicio está a punto de expirar. Quedan 15 segundos.',
          'unknown_error': 'Ocurrió un error desconocido.',
          'login_attempt_error':
              'Se produjo un error al intentar iniciar sesión.',
          'login_expired': 'La sesión de inicio ha expirado.',
          'login_processing_error':
              'Se produjo un error durante el procesamiento del inicio de sesión. Por favor, inténtalo de nuevo.',

          'login_cancelled': 'El inicio de sesión ha sido cancelado.',
          'invalid_login_request': 'Solicitud de inicio de sesión no válida.',
          'user_cancelled_login': 'El usuario canceló el inicio de sesión.',
          'server_error_occurred': 'Se ha producido un error en el servidor.',

          // New keys for LoginController
          'xumm_not_installed': 'Xaman no está instalado',
          'xumm_launch_failed': 'Error al iniciar Xaman',
          'null_status_received':
              'Se recibió un estado nulo del servicio Xaman',
          'invalid_account_data': 'Se recibieron datos de cuenta inválidos',

          'login_data_null': 'Los datos de inicio de sesión son nulos',
          'invalid_login_data_structure':
              'Estructura de datos de inicio de sesión inválida',

          // New keys for XummService
          'login_in_progress': 'Proceso de inicio de sesión ya en curso',
          'api_credentials_unavailable': 'Credenciales de API no disponibles',
          'unsupported_http_method': 'Método HTTP no soportado',
          'api_request_failed': 'Error en la solicitud de API',
          'api_response_parse_error':
              'Error al analizar la respuesta de la API',
          'xumm_login_instruction': 'Inicio de sesión Xsium',
          // Cierre de sesión
          'logout': 'Cerrar sesión',
          'logout_title': 'Cerrar sesión',
          'logout_confirm_message':
              '¿Estás seguro de que quieres cerrar sesión?',
          'logout_error_message':
              'Se produjo un error al cerrar sesión. Por favor, inténtalo de nuevo.',
          'logout_success': 'Sesión cerrada correctamente',

          // Pantalla de inicio
          'home': 'Inicio',
          'friends': 'Amigos',
          'chats': 'Chats',
          'canvas': 'Lienzo',
          'invites': 'Invitaciones',
          'exit_title': 'Salir de la aplicación',
          'exit_message': '¿Quieres salir de la aplicación?',
          'session_expired':
              'Sesión expirada. Por favor, inicia sesión de nuevo.',
          'logout_error': 'Error al cerrar sesión.',

          // Configuración
          'settings': 'Configuración',
          'theme': 'Tema',
          'language': 'Idioma',
          'dark_mode': 'Modo oscuro',
          'light_mode': 'Modo claro',
        },
      };
}
