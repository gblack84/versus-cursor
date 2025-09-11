import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleStorageKey = '__locale_key__';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static List<String> languages() => ['en', 'de'];

  static late SharedPreferences _prefs;
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();
  static Future storeLocale(String locale) =>
      _prefs.setString(_kLocaleStorageKey, locale);
  static Locale? getStoredLocale() {
    final locale = _prefs.getString(_kLocaleStorageKey);
    return locale != null && locale.isNotEmpty ? createLocale(locale) : null;
  }

  String get languageCode => locale.toString();
  String? get languageShortCode =>
      _languagesWithShortCode.contains(locale.toString())
          ? '${locale.toString()}_short'
          : null;
  int get languageIndex => languages().contains(languageCode)
      ? languages().indexOf(languageCode)
      : 0;

  String getText(String key) =>
      (kTranslationsMap[key] ?? {})[locale.toString()] ?? '';

  String getVariableText({
    String? enText = '',
    String? deText = '',
  }) =>
      [enText, deText][languageIndex] ?? '';

  static const Set<String> _languagesWithShortCode = {
    'ar',
    'az',
    'ca',
    'cs',
    'da',
    'de',
    'dv',
    'en',
    'es',
    'et',
    'fi',
    'fr',
    'gr',
    'he',
    'hi',
    'hu',
    'it',
    'km',
    'ku',
    'mn',
    'ms',
    'no',
    'pt',
    'ro',
    'ru',
    'rw',
    'sv',
    'th',
    'uk',
    'vi',
  };
}

/// Used if the locale is not supported by GlobalMaterialLocalizations.
class FallbackMaterialLocalizationDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      SynchronousFuture<MaterialLocalizations>(
        const DefaultMaterialLocalizations(),
      );

  @override
  bool shouldReload(FallbackMaterialLocalizationDelegate old) => false;
}

/// Used if the locale is not supported by GlobalCupertinoLocalizations.
class FallbackCupertinoLocalizationDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture<CupertinoLocalizations>(
        const DefaultCupertinoLocalizations(),
      );

  @override
  bool shouldReload(FallbackCupertinoLocalizationDelegate old) => false;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

Locale createLocale(String language) => language.contains('_')
    ? Locale.fromSubtags(
        languageCode: language.split('_').first,
        scriptCode: language.split('_').last,
      )
    : Locale(language);

bool _isSupportedLocale(Locale locale) {
  final language = locale.toString();
  return AppLocalizations.languages().contains(
    language.endsWith('_')
        ? language.substring(0, language.length - 1)
        : language,
  );
}

final kTranslationsMap = <Map<String, Map<String, String>>>[
  // Login_page
  {
    'b6l0k8k2': {
      'en': 'Email',
      'de': '',
    },
    '6l9ekgal': {
      'en': 'Password',
      'de': '',
    },
    '4wwn8ov8': {
      'en': 'Log in',
      'de': '',
    },
    'uk1cwrhu': {
      'en': 'Phone Log in',
      'de': '',
    },
    'ymtbo8l4': {
      'en': 'Forgot Password',
      'de': '',
    },
    'e1wsx5w1': {
      'en': 'Or sign up with, goto test',
      'de': '',
    },
    'zodqb7tr': {
      'en': 'Please enter a valid email address.',
      'de': '',
    },
    'j0tjwsb0': {
      'en': 'Please choose an option from the dropdown',
      'de': '',
    },
    'a3s2kg05': {
      'en': 'Password must be at least 6 characters',
      'de': '',
    },
    'h1k710sg': {
      'en': 'Please choose an option from the dropdown',
      'de': '',
    },
    '293kt2nw': {
      'en': 'Home',
      'de': '',
    },
  },
  // Create_Account
  {
    'hkdfn0nl': {
      'en': 'Welcome to\n           Versus Space',
      'de': '',
    },
    'r6bw196y': {
      'en': 'Create an account',
      'de': '',
    },
    'vyjbjx7u': {
      'en': 'Let\'s get started by filling out the form below.',
      'de': '',
    },
    'b4wuzum8': {
      'en': 'Email',
      'de': '',
    },
    'h5546n6k': {
      'en': 'Password',
      'de': '',
    },
    'dpnl6798': {
      'en': 'Confirm Password',
      'de': '',
    },
    'ifzwhrve': {
      'en': 'Create Account',
      'de': '',
    },
    'kfty848b': {
      'en': 'Create Account With Phone',
      'de': '',
    },
    'z9kzw84y': {
      'en':
          'By signing up, you agree to Versus Space\'s \n    Terms of Service, Privacy Policy, and Cookie Policy.',
      'de': '',
    },
    '0ksnf2xz': {
      'en': 'Already have an account? ',
      'de': '',
    },
    'do58zhdd': {
      'en': ' Log In here',
      'de': '',
    },
    'sfx28arj': {
      'en': 'Email is required',
      'de': '',
    },
    'fg4iipv6': {
      'en': 'Please enter a valid email address with domain.',
      'de': '',
    },
    'iagnl1sj': {
      'en': 'Please choose an option from the dropdown',
      'de': '',
    },
    'c10h5qqp': {
      'en': 'Password is required',
      'de': '',
    },
    'nlyzshnr': {
      'en': 'Please enter at least 8 characters.',
      'de': '',
    },
    'phds73eh': {
      'en': 'Please choose an option from the dropdown',
      'de': '',
    },
    'dv9ttawj': {
      'en': 'Confirm Password is required',
      'de': '',
    },
    'krbf7q4s': {
      'en': 'Please choose an option from the dropdown',
      'de': '',
    },
    'a1t3yg9y': {
      'en': 'Home',
      'de': '',
    },
  },
  // Forgot_Password
  {
    'vczmwqaz': {
      'en': 'Back',
      'de': '',
    },
    '6adpvif5': {
      'en': 'Forgot Password',
      'de': '',
    },
    'otjgw6ev': {
      'en':
          'We will send you an email with a link to reset your password, please enter the email associated with your account below.',
      'de': '',
    },
    '8mw92l30': {
      'en': 'Your email address...',
      'de': '',
    },
    'jabo9c3s': {
      'en': 'Enter your email...',
      'de': '',
    },
    '4rzuk0hj': {
      'en': 'Send Link',
      'de': '',
    },
    '7sfxx5v9': {
      'en': 'Back',
      'de': '',
    },
    'uhzqcthv': {
      'en': 'Home',
      'de': '',
    },
  },
  // user_info_input
  {
    'plunfug5': {
      'en': 'Information',
      'de': '',
    },
    '9bvrno9z': {
      'en': 'Display Name',
      'de': '',
    },
    'm58rgdkp': {
      'en': 'Display name*',
      'de': '',
    },
    'pqx67cpq': {
      'en': 'Language',
      'de': '',
    },
    'e2mae9l3': {
      'en': 'Gender',
      'de': '',
    },
    'fy3unoj5': {
      'en': 'Female',
      'de': '',
    },
    'sjv4inta': {
      'en': 'Male',
      'de': '',
    },
    'tmsnqk92': {
      'en': 'Other',
      'de': '',
    },
    'cn54l9bj': {
      'en': 'I confirm that I am at least ',
      'de': '',
    },
    'e8bfoncc': {
      'en': ' 13',
      'de': '',
    },
    'eqbsqvs2': {
      'en': '  years old.',
      'de': '',
    },
    '4165t2cs': {
      'en':
          'If you are under 13, providing false or misleading \ninformation may subject you to legal or administrative consequences.',
      'de': '',
    },
    'k84ryt65': {
      'en': 'Continue',
      'de': '',
    },
    'u59p36mu': {
      'en': 'Please enter the your display name.',
      'de': '',
    },
    'b2ia6l1p': {
      'en': 'Please choose an option from the dropdown',
      'de': '',
    },
    'jemkmkgu': {
      'en': 'Versus space',
      'de': '',
    },
    'sb1a093z': {
      'en': 'Home',
      'de': '',
    },
  },
  // testpage_select
  {
    'r6d1yxm7': {
      'en': 'Hello World',
      'de': '',
    },
    'x79ae4w2': {
      'en': 'Button',
      'de': '',
    },
    'y5m4a7vm': {
      'en': 'login',
      'de': '',
    },
    'df9krpqf': {
      'en': 'creat_ac',
      'de': '',
    },
    'unrhe499': {
      'en': 'forgot_ps',
      'de': '',
    },
    'd4vvfi1v': {
      'en': 'user_info\n',
      'de': '',
    },
    'e17ogwad': {
      'en': 'jopselect\n',
      'de': '',
    },
    '4ffxgxck': {
      'en': 'testalgolia\n',
      'de': '',
    },
    '87ap5nug': {
      'en': 'start',
      'de': '',
    },
    'oadbd0gy': {
      'en': 'phonelogin',
      'de': '',
    },
    '5fjkgyoa': {
      'en': 'homeAPosts',
      'de': '',
    },
    'pckw648z': {
      'en': 'editvideo',
      'de': '',
    },
    'un1ogy5i': {
      'en': 'image',
      'de': '',
    },
    'ln1qokjg': {
      'en': 'Button',
      'de': '',
    },
    'rbd8xke9': {
      'en': 'versus space',
      'de': '',
    },
    'cu01fdr4': {
      'en': 'Home',
      'de': '',
    },
  },
  // expertise_select
  {
    'lfhxure4': {
      'en': ', Tell us your expertise,',
      'de': '',
    },
    'wdoi0lud': {
      'en': '\nwe\'ll send you better questions.',
      'de': '',
    },
    'crcvslnv': {
      'en': 'What\'s your area of expertise?',
      'de': '',
    },
    'xirl42y4': {
      'en': 'expertise...',
      'de': '',
    },
    '5pspjm2b': {
      'en': 'You can add up to 4 items.',
      'de': '',
    },
    '2l833og3': {
      'en': 'Add',
      'de': '',
    },
    'qvwfh5oz': {
      'en': 'List.',
      'de': '',
    },
    'jvb8485b': {
      'en': 'Tip.',
      'de': '',
    },
    'r2cx59n4': {
      'en':
          ' Add your expertise tags (e.g. #coding, #investment) to see questions tailored to your interests.',
      'de': '',
    },
    'qdcvozij': {
      'en':
          '\n\n\"Which of these two coding frameworks should I use for my new project?\"',
      'de': '',
    },
    'qoetb929': {
      'en': '\n"Which tool is easier for beginner investors, A or B?"',
      'de': '',
    },
    'nb2efhx9': {
      'en': 'Next',
      'de': '',
    },
    '519xixp4': {
      'en': 'versus space',
      'de': '',
    },
    'sf4vca89': {
      'en': 'Home',
      'de': '',
    },
  },
  // testalgoria
  {
    '4ofzrgyp': {
      'en': 'TextField',
      'de': '',
    },
    'fafdx2pw': {
      'en': 'Page Title',
      'de': '',
    },
    '3miu98e5': {
      'en': 'Home',
      'de': '',
    },
  },
  // hobbies_select
  {
    'jnha4tov': {
      'en': ' Next, share your hobbies and interests!',
      'de': '',
    },
    's6khifdw': {
      'en': '\nWe\'ll tailor recommendations to your personal passions.',
      'de': '',
    },
    '8cyk6y1f': {
      'en': 'What are your hobbies or interests?',
      'de': '',
    },
    'kh1x2j64': {
      'en': 'hobby or interest…',
      'de': '',
    },
    'qdn4sbni': {
      'en': 'You can add up to 8 items.',
      'de': '',
    },
    '0a61zfnb': {
      'en': 'Add',
      'de': '',
    },
    'tial28r9': {
      'en': 'List.',
      'de': '',
    },
    'ddy2vf0h': {
      'en': 'Tip.',
      'de': '',
    },
    'ap7dkw8g': {
      'en':
          ' Add your favorite hobbies or interests (e.g. #travel, #sports) to see content tailored to your passions.',
      'de': '',
    },
    'r0p1jhwa': {
      'en':
          '\n\n"Which instrument is more beginner-friendly, guitar or piano?"',
      'de': '',
    },
    'ng6aurtj': {
      'en':
          '\n"For a short getaway, would you prefer a guided city tour or a nature retreat?"',
      'de': '',
    },
    '0m7oqr3n': {
      'en': 'Next',
      'de': '',
    },
    'flvvuyvo': {
      'en': 'versus space',
      'de': '',
    },
    'prkzyejg': {
      'en': 'Home',
      'de': '',
    },
  },
  // agrred_select
  {
    '17zx9oh1': {
      'en': ' Next, share your hobbies and interests!',
      'de': '',
    },
    'xxz7ej5s': {
      'en': '\nWe\'ll tailor recommendations to your personal passions.',
      'de': '',
    },
    'u7v4k6jw': {
      'en': 'What are your hobbies or interests?',
      'de': '',
    },
    '278cy82i': {
      'en': 'hobby or interest…',
      'de': '',
    },
    'zpkdrkrf': {
      'en': 'You can add up to 8 items.',
      'de': '',
    },
    'ij0f81vj': {
      'en': 'Add',
      'de': '',
    },
    'okzh5b2z': {
      'en': 'List.',
      'de': '',
    },
    'medehueg': {
      'en': 'Tip.',
      'de': '',
    },
    '1ppulwvg': {
      'en':
          ' Add your favorite hobbies or interests (e.g. #travel, #sports) to see content tailored to your passions.',
      'de': '',
    },
    'bsanq3ez': {
      'en':
          '\n\n"Which instrument is more beginner-friendly, guitar or piano?"',
      'de': '',
    },
    'k1wz4a90': {
      'en':
          '\n"For a short getaway, would you prefer a guided city tour or a nature retreat?"',
      'de': '',
    },
    'i8rpxq4t': {
      'en': 'Next',
      'de': '',
    },
    '1kaqp8o7': {
      'en': 'versus space',
      'de': '',
    },
    '6oe2nnzd': {
      'en': 'Home',
      'de': '',
    },
  },
  // start_page
  {
    'ur72jrvo': {
      'en': 'Life is a \'c\' between \'b\' and \'d\'',
      'de': '',
    },
    'tkccfqfy': {
      'en': 'Go To Create Account',
      'de': '',
    },
    '3gnrvqoi': {
      'en': 'Continue with Apple',
      'de': '',
    },
    's24g5s5d': {
      'en': 'Continue with Google',
      'de': '',
    },
    'ntv3cl1f': {
      'en': 'Continue with Facebook',
      'de': '',
    },
    '4ssf49xr': {
      'en': 'Continue with Instagram',
      'de': '',
    },
    'b71h3bzp': {
      'en': 'Go To Sign in',
      'de': '',
    },
    'x52aa05l': {
      'en': 'Home',
      'de': '',
    },
  },
  // testdivider
  {
    '820vo5vt': {
      'en': 'Page Title',
      'de': '',
    },
    's2ndilcz': {
      'en': 'Home',
      'de': '',
    },
  },
  // PhoneCreatAccount
  {
    'gwbbszpy': {
      'en': 'Phone Login',
      'de': '',
    },
    'xv3gqx8x': {
      'en':
          'Please enter your phone number below.\nWe\'ll send a verification code via SMS.\nOnce you receive the code, enter it here to log in.',
      'de': '',
    },
    '3rvgi38u': {
      'en': '+Code',
      'de': '',
    },
    'kna6yami': {
      'en': 'Your Phone Number...',
      'de': '',
    },
    'npd3p5vi': {
      'en': 'Enter your Phone Number...',
      'de': '',
    },
    'pqidvgqu': {
      'en': 'Send  Code',
      'de': '',
    },
    'qgyftxro': {
      'en': 'Back',
      'de': '',
    },
    '599ek3fb': {
      'en': 'Home',
      'de': '',
    },
  },
  // Phonelogeinpincode
  {
    'daf828ek': {
      'en': 'Phone Login',
      'de': '',
    },
    'ddk0vrr5': {
      'en':
          'Please enter your phone number below.\nWe\'ll send a verification code via SMS.\nOnce you receive the code, enter it here to log in.',
      'de': '',
    },
    '6lsg39md': {
      'en': '\nEnter the 6-digit code sent to your phone.',
      'de': '',
    },
    'ep61t57h': {
      'en': 'Authentication succeeded!!',
      'de': '',
    },
    '85h4oe02': {
      'en': 'Authentication failed. Please try again.',
      'de': '',
    },
    '7ezietmr': {
      'en': 'Re Code',
      'de': '',
    },
    'pyfnfxye': {
      'en':
          'Tip. If you haven\'t received it, try resending or check your phone number.',
      'de': '',
    },
    'xjt78grf': {
      'en': 'Next',
      'de': '',
    },
    'bjt41bts': {
      'en': 'Back',
      'de': '',
    },
    '8wbm2zg3': {
      'en': 'Home',
      'de': '',
    },
  },
  // blankppp
  {
    '0y0b5bpx': {
      'en': 'Page Title',
      'de': '',
    },
    'erkqyrow': {
      'en': 'Email',
      'de': '',
    },
    'tcloodtg': {
      'en': 'Password',
      'de': '',
    },
    '0qwo5ebl': {
      'en': 'log in',
      'de': '',
    },
    'mgoq8vt1': {
      'en': 'Forgot Password',
      'de': '',
    },
    's44z3wif': {
      'en': 'Or sign up with, goto test',
      'de': '',
    },
    'zg9cqede': {
      'en': 'Home',
      'de': '',
    },
  },
  // HomeAndPosts
  {
    'x39v6lyp': {
      'en': 'Page Title',
      'de': '',
    },
    '100mlae4': {
      'en': 'Home',
      'de': '',
    },
  },
  // HomeAndPostsCopy
  {
    'cksdlwvw': {
      'en': 'Page Title',
      'de': '',
    },
    'xwrcpz9v': {
      'en': 'A',
      'de': '',
    },
    'hddxeylg': {
      'en': 'B',
      'de': '',
    },
    'g32j8ys3': {
      'en': 'Home',
      'de': '',
    },
  },
  // editvideoP
  {
    '6vxfvxd1': {
      'en': 'upload',
      'de': '',
    },
    'v6lswlmj': {
      'en': 'cancle',
      'de': '',
    },
    'imk8y17a': {
      'en': 'Page Title',
      'de': '',
    },
    'ufuh95zc': {
      'en': 'Home',
      'de': '',
    },
  },
  // editvideopp
  {
    'px8eovob': {
      'en': 'Home',
      'de': '',
    },
  },
  // ImageEditorPage
  {
    '3fjanic0': {
      'en': 'Home',
      'de': '',
    },
  },
  // InPutPostImage
  {
    '5kzcbgop': {
      'en': 'Question Title',
      'de': '',
    },
    'jr6l0zdb': {
      'en': 'Enter question title',
      'de': '',
    },
    'fw81zr5s': {
      'en': 'A',
      'de': '',
    },
    'ncslnwz1': {
      'en': 'B',
      'de': '',
    },
    'ma3u1a6g': {
      'en': 'A',
      'de': '',
    },
    '6nrudz4v': {
      'en': 'B',
      'de': '',
    },
    '94dz6d39': {
      'en': 'Description',
      'de': '',
    },
    'gipyr3sq': {
      'en': 'Enter Description',
      'de': '',
    },
    'jvx92fb4': {
      'en': 'A title',
      'de': '',
    },
    'tkzl6wqo': {
      'en': 'Tell me about A...',
      'de': '',
    },
    't8flxbe7': {
      'en': 'B title',
      'de': '',
    },
    'gwsufdly': {
      'en': 'Tell me about B...',
      'de': '',
    },
    'w04dob8j': {
      'en': 'Page Title',
      'de': '',
    },
    'mi9fnta8': {
      'en': 'Home',
      'de': '',
    },
  },
  // TagsLabels
  {
    'hq8fohiq': {
      'en': '#website',
      'de': '',
    },
    'zpugyk8p': {
      'en': '#ux',
      'de': '',
    },
    '3rcbycua': {
      'en': '#versus',
      'de': '',
    },
  },
  // vsmark
  {
    'abejuxne': {
      'en': 'Versus',
      'de': '',
    },
  },
  // PopupTimerEmail
  {
    'ajk36y0p': {
      'en': 'Email verification in progress.',
      'de': '',
    },
    'zustpgk9': {
      'en': 'Check your Email,\n',
      'de': '',
    },
    'c3ope0t7': {
      'en': 'Edit Email..',
      'de': '',
    },
    'yqb182uz': {
      'en': 'Re Send..',
      'de': '',
    },
  },
  // Phonemaximum
  {
    '3dcoy1cp': {
      'en': 'You have exceeded the maximum of 3 resend attempts.',
      'de': '',
    },
    'vgyx5a8r': {
      'en': 'Ok',
      'de': '',
    },
  },
  // Phoneloginpincode
  {
    'usvyes4j': {
      'en': 'Email verification in progress.',
      'de': '',
    },
    'h0xldpn5': {
      'en': 'Check your Email,\n',
      'de': '',
    },
    'w7b2rjfw': {
      'en': 'Hello World',
      'de': '',
    },
  },
  // CharacterDetailPage
  {
    '5dgi9ixf': {
      'en': 'Apply',
      'de': '',
    },
    'jtczffcg': {
      'en': 'Gallery / Camera',
      'de': '',
    },
  },
  // InPutText
  {
    'w5drxgwf': {
      'en': 'TextField',
      'de': '',
    },
    '0zfp2fn2': {
      'en': 'sheetText is required',
      'de': '',
    },
    '1k8j3n9p': {
      'en': 'Please choose an option from the dropdown',
      'de': '',
    },
    'uvtnvfi7': {
      'en': 'Button',
      'de': '',
    },
    'prw75byg': {
      'en': 'Hello World',
      'de': '',
    },
  },
  // InPutImage
  {
    'yaggfmwm': {
      'en': 'Gallary',
      'de': '',
    },
    '63hun11y': {
      'en': 'Camera',
      'de': '',
    },
    'bwlvl54v': {
      'en': 'Button',
      'de': '',
    },
    'k73btvmc': {
      'en': 'Hello World',
      'de': '',
    },
  },
  // emptyalert
  {
    'd0ji9xsm': {
      'en': 'No Text Entered',
      'de': '',
    },
    '8iwxyn0s': {
      'en':
          'The text field is empty. If you close now, your previously saved text will be lost.',
      'de': '',
    },
    '5noy5w0s': {
      'en': 'Ok',
      'de': '',
    },
  },
  // alertempty
  {
    '707q86sk': {
      'en': 'No Text Entered',
      'de': '',
    },
    'sz1sjey3': {
      'en':
          'The text field is empty. If you close now, your previously saved text will be lost.',
      'de': '',
    },
    'xhyu1hyf': {
      'en': 'Ok',
      'de': '',
    },
  },
  // InPutIvideo
  {
    '5j8wn3ec': {
      'en': 'Gallary',
      'de': '',
    },
    '6qo02jch': {
      'en': 'Back',
      'de': '',
    },
    'wg4l2nxs': {
      'en': 'apply',
      'de': '',
    },
    '7ngao819': {
      'en': 'YuTube',
      'de': '',
    },
    'qh625dmg': {
      'en': 'YouTube',
      'de': '',
    },
    '7gqk5lt5': {
      'en': 'TextField',
      'de': '',
    },
    'bzs7qsx8': {
      'en': 'Link',
      'de': '',
    },
    '171yaxvn': {
      'en': 'Link    ',
      'de': '',
    },
    'ehmkbuuc': {
      'en': '- Shorts',
      'de': '',
    },
    'jtwrhql9': {
      'en': 'TextField',
      'de': '',
    },
    '448u8u21': {
      'en': 'Apply',
      'de': '',
    },
    'hy93en4y': {
      'en': 'Hello World',
      'de': '',
    },
  },
  // editviedo
  {
    '613h5dwl': {
      'en': 'Hello World',
      'de': '',
    },
    'h9yoweew': {
      'en': 'Hello World',
      'de': '',
    },
    'g405hkr8': {
      'en': 'upload',
      'de': '',
    },
    'r3qip94t': {
      'en': 'cancle',
      'de': '',
    },
  },
  // uploadChoiceBottomSheet
  {
    'i36a91le': {
      'en': 'Gallery',
      'de': '',
    },
    '16rkqdde': {
      'en': 'Camera',
      'de': '',
    },
  },
  // Miscellaneous
  {
    '29m1hzk8': {
      'en': '',
      'de': '',
    },
    'yh7e4qeq': {
      'en': '',
      'de': '',
    },
    'gp947i66': {
      'en': '',
      'de': '',
    },
    'tr194mk6': {
      'en': '',
      'de': '',
    },
    'rbopmhq9': {
      'en': '',
      'de': '',
    },
    '1bljlacq': {
      'en': '',
      'de': '',
    },
    'i73k5t8v': {
      'en': '',
      'de': '',
    },
    'ao9qmgqm': {
      'en': '',
      'de': '',
    },
    'm7jdnh1u': {
      'en': '',
      'de': '',
    },
    '3o3nn93a': {
      'en': '',
      'de': '',
    },
    'jd9hhqz8': {
      'en': '',
      'de': '',
    },
    'jlsw03bu': {
      'en': '',
      'de': '',
    },
    '5uwu5vul': {
      'en': '',
      'de': '',
    },
    'l2fx117x': {
      'en': '',
      'de': '',
    },
    '66absala': {
      'en': '',
      'de': '',
    },
    'eorrndcb': {
      'en': '',
      'de': '',
    },
    'b3dl38xi': {
      'en': '',
      'de': '',
    },
    '4st3oxse': {
      'en': '',
      'de': '',
    },
    'exqyr4ok': {
      'en': '',
      'de': '',
    },
    'nlmzt7vq': {
      'en': '',
      'de': '',
    },
    '774e6yf3': {
      'en': '',
      'de': '',
    },
    'v9r77mba': {
      'en': '',
      'de': '',
    },
    'a5gxuhtu': {
      'en': '',
      'de': '',
    },
    'bk9ujrc5': {
      'en': '',
      'de': '',
    },
    'dct26121': {
      'en': '',
      'de': '',
    },
    'jstic31n': {
      'en': '',
      'de': '',
    },
    '82w032fm': {
      'en': '',
      'de': '',
    },
    'jfr76ob1': {
      'en': '',
      'de': '',
    },
  },
].reduce((a, b) => a..addAll(b));
