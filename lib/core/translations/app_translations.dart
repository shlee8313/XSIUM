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
              'Scan the QR code below with the XUMM app on another device.',
          'login_error': 'Login failed. Please try again.',

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

          // 로그인 화면
          'welcome_message': 'Xsium에 오신 것을 환영합니다',
          'login_this_device': '이 기기에서 로그인',
          'login_other_device': '다른 기기에서 로그인',
          'qr_login_title': 'QR 코드 로그인',
          'qr_login_instruction': '다른 기기의 XUMM 앱으로 아래 QR 코드를 스캔하세요.',
          'login_error': '로그인에 실패했습니다. 다시 시도해주세요.',

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

          // ログイン画面
          'welcome_message': 'Xsiumへようこそ',
          'login_this_device': 'この端末でログイン',
          'login_other_device': '他の端末でログイン',
          'qr_login_title': 'QRコードログイン',
          'qr_login_instruction': '他の端末のXUMMアプリで以下のQRコードをスキャンしてください。',
          'login_error': 'ログインに失敗しました。もう一度お試しください。',

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

          // Pantalla de inicio de sesión
          'welcome_message': 'Bienvenido a Xsium',
          'login_this_device': 'Iniciar sesión en este dispositivo',
          'login_other_device': 'Iniciar sesión en otro dispositivo',
          'qr_login_title': 'Inicio de sesión con código QR',
          'qr_login_instruction':
              'Escanea el código QR con la aplicación XUMM en otro dispositivo.',
          'login_error':
              'Error al iniciar sesión. Por favor, inténtalo de nuevo.',

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
