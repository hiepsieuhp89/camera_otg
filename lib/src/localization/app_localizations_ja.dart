// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Smart Buddy';

  @override
  String get pleaseSelectAreaAndContractor => '点検エリアを選択ください';

  @override
  String get showBridgeList => '橋リストを表示';

  @override
  String get bridgeListTitle => '点検橋を選択ください';

  @override
  String get unableToLoadBridges => '橋をロードできません';

  @override
  String get takePictureTitle => '写真撮影';

  @override
  String get takePictureDone => '終わり';

  @override
  String get previewPicturesTitle => 'プレビュー画像';

  @override
  String get noDamageFound => '損傷なし';

  @override
  String finishedTasks(Object finished, Object total) {
    return '$finished/$total 完了';
  }

  @override
  String get startInspection => '点検開始';

  @override
  String get finishInspection => '点検終了';

  @override
  String get finishEvaluation => '入力完了';

  @override
  String get inspectionWasSkipped => '点検をスキップした。';

  @override
  String get skipEvaluation => '入力省略';

  @override
  String lastInspectionDate(Object dateTime) {
    return '最終点検日時：$dateTime';
  }

  @override
  String inspectionDate(Object dateTime) {
    return '点検日時：$dateTime';
  }

  @override
  String get municipalityName => '市町村';

  @override
  String get contractorName => '点検業者';

  @override
  String get cancelInspectionConfirm => 'キャンセルすると、完了した点検の情報が削除されます。キャンセルしますか';

  @override
  String get cancelInspection => '点検キャンセル';

  @override
  String get noPreviousImageFound => '前回の画像が見つかりません';

  @override
  String get lastInspectionPhoto => '前回の写真';

  @override
  String get damageType => '対象部材';

  @override
  String get damageDetails => '損傷種類';

  @override
  String get damage => '損傷度';

  @override
  String get remark => '備考';

  @override
  String get damageLevel => '損傷度';

  @override
  String get lastTime => '前回';

  @override
  String get thisTime => '今回';

  @override
  String get noDataYet => 'まだデータはありません';

  @override
  String get targetMaterial => '対象部材';

  @override
  String get pleaseSelectAPhoto => '採用用写真を選択してください';

  @override
  String get failedToCreateInspectionReport => '点検報告書の作成に失敗しました';

  @override
  String get failedToGetInspectionPoints => '点検ポイントの取得に失敗しました';

  @override
  String get allInspection => '全点検';

  @override
  String get presentConditionInspection => '現況点検';

  @override
  String get damageInspection => '損傷点検';

  @override
  String get finished => '完了';

  @override
  String get capturedPhotos => '撮影写真';

  @override
  String get diagramPicture => '図面';

  @override
  String get continueInspecting => '続行';

  @override
  String get diagramSelection => '図面選択';

  @override
  String get newDiagramPhotos => '新しい図面写真';

  @override
  String get currentDiagramPhotos => '現在の図面写真';

  @override
  String get takePhoto => '写真撮影';

  @override
  String get selectPhoto => '写真選択';

  @override
  String get noPhotosYet => '写真がありません';

  @override
  String get damageMarking => '損傷箇所マーキング';

  @override
  String get newDamage => '新規損傷';

  @override
  String get name => '部材名';

  @override
  String get spanNumber => '径間番号';

  @override
  String get elementNumber => '要素番号';

  @override
  String get createThenEvalutatePoints => '点検ポイントを作成してください';

  @override
  String get createInspectionPoints => '点検ポイント作成';

  @override
  String get createDamageInspectionPoint => '損傷箇所作成';

  @override
  String get createPresentConditionInspectionPoint => '現況箇所作成';

  @override
  String get inspectionPoint => '点検ポイント';

  @override
  String get pleaseFinishAllInspectionPoints => '全ての点検ポイントを完了してください';

  @override
  String get setPreferredPhoto => '採用写真とする';

  @override
  String photoRefNumber(Object number) {
    return '写真番号$number';
  }

  @override
  String get noPastPhotoFound => '過去の写真が見つかりません';

  @override
  String get confirmationForNoPhoto => '写真撮影が完了していませんが、よろしいですか？';

  @override
  String get yesOption => '「YES」';

  @override
  String get noOption => '「NO」';

  @override
  String get skip => 'スキップ';

  @override
  String confirmationForReinspection(Object photoRefNumber) {
    return '$photoRefNumberを再点検したいですか？';
  }

  @override
  String get finishInspectionConfirm => 'まだ点検されない項目があります。点検を終了してもよろしいですか？';

  @override
  String get backToInspectingConfirm => '点検中に戻してよろしいですか？';

  @override
  String get backToInspecting => '点検中に戻る';

  @override
  String get holdButton => '保留';

  @override
  String get inspectionPointFilters => '点検ポイントフィルタ';

  @override
  String get inspectionStatus => '点検状況';

  @override
  String get statusNotInspected => '未点検';

  @override
  String get statusFinished => '完了';

  @override
  String get statusOnHold => '保留';

  @override
  String get statusSkipped => 'スキップ';

  @override
  String get loginButton => 'ログイン';

  @override
  String get logoutButton => 'ログアウト';

  @override
  String get comparePhotos => '写真比較';

  @override
  String get selectAndOrderPhotos => '写真選択と並び替え';

  @override
  String get errorFinishingInspection => '点検終了時にエラーが発生しました';

  @override
  String get pendingReportsWarning => '保留点検が存在しておりますので、点検完了ができません。';

  @override
  String get splashScreenCheckingForAuthenticated => '認証情報を確認中';

  @override
  String get splashScreenLoadingData => 'データをロード中';

  @override
  String get splashScreenCheckingForUpdates => 'アップデートを確認中';

  @override
  String get appUpdate => 'アプリ更新';

  @override
  String get appUpdateTitle => '新しいバージョンがあります';

  @override
  String get appUpdateMessage => '新しいバージョンが利用可能です。アプリを更新する必要があります';

  @override
  String currentVersion(Object version) {
    return '現在バージョン: $version';
  }

  @override
  String updateVersion(Object version) {
    return '最新バージョン: $version';
  }

  @override
  String get appUpdateInstallPermissionRequired => 'アプリの更新をインストールするためには、インストールの許可が必要です';

  @override
  String get install => 'インストール';

  @override
  String span(Object number) {
    return '$number径間';
  }

  @override
  String get noSpan => '径間無し';

  @override
  String get pressAndHoldForMarking => '長押しでマーク位置を移動';

  @override
  String get emptyDamageDiagramWarning => '図面を選択してください';

  @override
  String get selectDiagramButton => '図面を選択';

  @override
  String get changeDiagramButton => '図面を変更';

  @override
  String get updateInspectionPoints => '点検ポイントを更新';

  @override
  String get selectDiagramWarning => '図面を選択してください';

  @override
  String get failedToSubmitInspectionPointReport => '点検ポイント報告書の提出に失敗しました';

  @override
  String get submittedInspectionPointReport => '点検ポイント報告書を提出しました';

  @override
  String get retry => '再試行';

  @override
  String suggestionsCount(Object count) {
    return '$count 候補';
  }

  @override
  String get editDiagram => '図面を編集';
  
  @override
  String failedToSaveSketch(Object error) {
    return 'スケッチの保存に失敗しました: $error';
  }
  
  @override
  String get brushSettings => 'ブラシ設定';
  
  @override
  String get textSettings => 'テキスト設定';
  
  @override
  String get shapeSettings => '図形設定';
  
  @override
  String get width => '太さ:';
  
  @override
  String get color => '色:';
  
  @override
  String get size => 'サイズ:';
  
  @override
  String get fill => '塗りつぶし:';
  
  @override
  String get addShape => '図形を追加';
  
  @override
  String get none => 'なし';
  
  @override
  String get line => '線';
  
  @override
  String get arrow => '矢印';
  
  @override
  String get doubleArrow => '双方向矢印';
  
  @override
  String get rectangle => '長方形';
  
  @override
  String get oval => '楕円';
}
