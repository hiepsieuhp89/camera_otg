import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ja.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ja')
  ];

  /// Smart Buddy
  ///
  /// In ja, this message translates to:
  /// **'Smart Buddy'**
  String get appTitle;

  /// No description provided for @pleaseSelectAreaAndContractor.
  ///
  /// In ja, this message translates to:
  /// **'点検エリアを選択ください'**
  String get pleaseSelectAreaAndContractor;

  /// No description provided for @showBridgeList.
  ///
  /// In ja, this message translates to:
  /// **'橋リストを表示'**
  String get showBridgeList;

  /// No description provided for @bridgeListTitle.
  ///
  /// In ja, this message translates to:
  /// **'点検橋を選択ください'**
  String get bridgeListTitle;

  /// No description provided for @unableToLoadBridges.
  ///
  /// In ja, this message translates to:
  /// **'橋をロードできません'**
  String get unableToLoadBridges;

  /// No description provided for @takePictureTitle.
  ///
  /// In ja, this message translates to:
  /// **'写真撮影'**
  String get takePictureTitle;

  /// No description provided for @takePictureDone.
  ///
  /// In ja, this message translates to:
  /// **'終わり'**
  String get takePictureDone;

  /// No description provided for @previewPicturesTitle.
  ///
  /// In ja, this message translates to:
  /// **'プレビュー画像'**
  String get previewPicturesTitle;

  /// No description provided for @noDamageFound.
  ///
  /// In ja, this message translates to:
  /// **'損傷なし'**
  String get noDamageFound;

  /// The number of tasks finished out of total
  ///
  /// In ja, this message translates to:
  /// **'{finished}/{total} 完了'**
  String finishedTasks(Object finished, Object total);

  /// No description provided for @startInspection.
  ///
  /// In ja, this message translates to:
  /// **'点検開始'**
  String get startInspection;

  /// No description provided for @finishInspection.
  ///
  /// In ja, this message translates to:
  /// **'点検終了'**
  String get finishInspection;

  /// No description provided for @finishEvaluation.
  ///
  /// In ja, this message translates to:
  /// **'入力完了'**
  String get finishEvaluation;

  /// Last inspection date and time
  ///
  /// In ja, this message translates to:
  /// **'最終点検日時：{dateTime}'**
  String lastInspectionDate(Object dateTime);

  /// No description provided for @municipalityName.
  ///
  /// In ja, this message translates to:
  /// **'市町村'**
  String get municipalityName;

  /// No description provided for @contractorName.
  ///
  /// In ja, this message translates to:
  /// **'点検業者'**
  String get contractorName;

  /// No description provided for @cancelInspectionConfirm.
  ///
  /// In ja, this message translates to:
  /// **'キャンセルすると、完了した点検の情報が削除されます。キャンセルしますか'**
  String get cancelInspectionConfirm;

  /// No description provided for @cancelInspection.
  ///
  /// In ja, this message translates to:
  /// **'点検キャンセル'**
  String get cancelInspection;

  /// No description provided for @noPreviousImageFound.
  ///
  /// In ja, this message translates to:
  /// **'前回の画像が見つかりません'**
  String get noPreviousImageFound;

  /// No description provided for @lastInspectionPhoto.
  ///
  /// In ja, this message translates to:
  /// **'前回の写真'**
  String get lastInspectionPhoto;

  /// No description provided for @damageType.
  ///
  /// In ja, this message translates to:
  /// **'対象部材'**
  String get damageType;

  /// No description provided for @damageDetails.
  ///
  /// In ja, this message translates to:
  /// **'損傷の種類'**
  String get damageDetails;

  /// No description provided for @damage.
  ///
  /// In ja, this message translates to:
  /// **'損傷度'**
  String get damage;

  /// No description provided for @remark.
  ///
  /// In ja, this message translates to:
  /// **'備考'**
  String get remark;

  /// No description provided for @pleaseSelectAPhoto.
  ///
  /// In ja, this message translates to:
  /// **'採用用写真を選択してください'**
  String get pleaseSelectAPhoto;

  /// No description provided for @failedToCreateInspectionReport.
  ///
  /// In ja, this message translates to:
  /// **'点検報告書の作成に失敗しました'**
  String get failedToCreateInspectionReport;

  /// No description provided for @failedToGetInspectionPoints.
  ///
  /// In ja, this message translates to:
  /// **'点検ポイントの取得に失敗しました'**
  String get failedToGetInspectionPoints;

  /// No description provided for @allInspection.
  ///
  /// In ja, this message translates to:
  /// **'全点検'**
  String get allInspection;

  /// No description provided for @presentConditionInspection.
  ///
  /// In ja, this message translates to:
  /// **'現況点検'**
  String get presentConditionInspection;

  /// No description provided for @damageInspection.
  ///
  /// In ja, this message translates to:
  /// **'損傷点検'**
  String get damageInspection;

  /// No description provided for @finished.
  ///
  /// In ja, this message translates to:
  /// **'完了'**
  String get finished;

  /// No description provided for @capturedPhotos.
  ///
  /// In ja, this message translates to:
  /// **'撮影写真'**
  String get capturedPhotos;

  /// No description provided for @diagramPicture.
  ///
  /// In ja, this message translates to:
  /// **'図面'**
  String get diagramPicture;

  /// No description provided for @continueInspecting.
  ///
  /// In ja, this message translates to:
  /// **'続行'**
  String get continueInspecting;

  /// No description provided for @diagramSelection.
  ///
  /// In ja, this message translates to:
  /// **'図面選択'**
  String get diagramSelection;

  /// No description provided for @newDiagramPhotos.
  ///
  /// In ja, this message translates to:
  /// **'新しい図面写真'**
  String get newDiagramPhotos;

  /// No description provided for @currentDiagramPhotos.
  ///
  /// In ja, this message translates to:
  /// **'現在の図面写真'**
  String get currentDiagramPhotos;

  /// No description provided for @takePhoto.
  ///
  /// In ja, this message translates to:
  /// **'写真撮影'**
  String get takePhoto;

  /// No description provided for @selectPhoto.
  ///
  /// In ja, this message translates to:
  /// **'写真選択'**
  String get selectPhoto;

  /// No description provided for @noPhotosYet.
  ///
  /// In ja, this message translates to:
  /// **'写真がありません'**
  String get noPhotosYet;

  /// No description provided for @damageMarking.
  ///
  /// In ja, this message translates to:
  /// **'損傷箇所マーキング'**
  String get damageMarking;

  /// No description provided for @pleaseTapOnWhereTheDamageLocates.
  ///
  /// In ja, this message translates to:
  /// **'損傷箇所をタップしてください'**
  String get pleaseTapOnWhereTheDamageLocates;

  /// No description provided for @newDamage.
  ///
  /// In ja, this message translates to:
  /// **'新規損傷'**
  String get newDamage;

  /// No description provided for @name.
  ///
  /// In ja, this message translates to:
  /// **'名前'**
  String get name;

  /// No description provided for @createThenEvalutatePoints.
  ///
  /// In ja, this message translates to:
  /// **'点検ポイントを作成してください'**
  String get createThenEvalutatePoints;

  /// No description provided for @createInspectionPoints.
  ///
  /// In ja, this message translates to:
  /// **'点検ポイント作成'**
  String get createInspectionPoints;

  /// No description provided for @inspectionPoint.
  ///
  /// In ja, this message translates to:
  /// **'点検ポイント'**
  String get inspectionPoint;

  /// No description provided for @pleaseFinishAllInspectionPoints.
  ///
  /// In ja, this message translates to:
  /// **'全ての点検ポイントを完了してください'**
  String get pleaseFinishAllInspectionPoints;

  /// No description provided for @setPreferredPhoto.
  ///
  /// In ja, this message translates to:
  /// **'採用写真とする'**
  String get setPreferredPhoto;

  /// Reference number of inspection point in diagram photo
  ///
  /// In ja, this message translates to:
  /// **'写真番号{number}'**
  String photoRefNumber(Object number);

  /// No description provided for @noPastPhotoFound.
  ///
  /// In ja, this message translates to:
  /// **'過去の写真が見つかりません'**
  String get noPastPhotoFound;

  /// No description provided for @goToPhotoSelectionButton.
  ///
  /// In ja, this message translates to:
  /// **'過年度写真表示'**
  String get goToPhotoSelectionButton;

  /// No description provided for @confirmationForNoPhoto.
  ///
  /// In ja, this message translates to:
  /// **'写真撮影していないけどいいですか'**
  String get confirmationForNoPhoto;

  /// No description provided for @yesOption.
  ///
  /// In ja, this message translates to:
  /// **'「YES」'**
  String get yesOption;

  /// No description provided for @noOption.
  ///
  /// In ja, this message translates to:
  /// **'「NO」'**
  String get noOption;

  /// No description provided for @skip.
  ///
  /// In ja, this message translates to:
  /// **'スキップ'**
  String get skip;

  /// photo reference number
  ///
  /// In ja, this message translates to:
  /// **'{photoRefNumber}を再点検したいですか？'**
  String confirmationForReinspection(Object photoRefNumber);

  /// No description provided for @finishInspectionConfirm.
  ///
  /// In ja, this message translates to:
  /// **'まだ点検されない項目があります。点検を終了してもよろしいですか？'**
  String get finishInspectionConfirm;

  /// No description provided for @backToInspectingConfirm.
  ///
  /// In ja, this message translates to:
  /// **'点検中に戻してよろしいですか？'**
  String get backToInspectingConfirm;

  /// No description provided for @backToInspecting.
  ///
  /// In ja, this message translates to:
  /// **'点検中に戻る'**
  String get backToInspecting;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ja': return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
