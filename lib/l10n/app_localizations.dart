import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[
    Locale('fr'),
    Locale('en'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final localizations =
        Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(localizations != null,
        'AppLocalizations is not available in the widget tree.');
    return localizations ?? const AppLocalizations(Locale('fr'));
  }

  bool get isFrench => locale.languageCode == 'fr';

  String tr({required String fr, required String en}) => isFrench ? fr : en;

  String helloUser(String name) => tr(fr: 'Bonjour, $name', en: 'Hello, $name');
  String get hello => tr(fr: 'Bonjour', en: 'Hello');

  String genericError(String message) => tr(
        fr: 'Erreur : $message',
        en: 'Error: $message',
      );

  String uploadFailed(String message) => tr(
        fr: 'Échec du téléversement : $message',
        en: 'Upload failed: $message',
      );

  String filesUploaded(int count) => tr(
        fr: '$count fichier(s) téléversé(s)',
        en: '$count file(s) uploaded',
      );

  String fileTooLarge(String fileName) => tr(
        fr: '$fileName dépasse la limite de 25 Mo',
        en: '$fileName exceeds 25 MB limit',
      );

  String failedToDownload(String message) => tr(
        fr: 'Échec du téléchargement : $message',
        en: 'Failed to download: $message',
      );

  String deleteDocumentConfirm(String fileName) => tr(
        fr: 'Supprimer "$fileName" ? Cette action est irréversible.',
        en: 'Delete "$fileName"? This action cannot be undone.',
      );

  String failedToDelete(String message) => tr(
        fr: 'Échec de la suppression : $message',
        en: 'Failed to delete: $message',
      );

  String pageNotFound(String uri) => tr(
        fr: 'Page introuvable : $uri',
        en: 'Page not found: $uri',
      );

  String invalidNumericValue() => tr(
        fr: 'Valeur numérique invalide.',
        en: 'Invalid numeric value.',
      );

  String dataSaved() => tr(
        fr: 'Donnée enregistrée.',
        en: 'Data saved.',
      );

  String get retry => tr(fr: 'Réessayer', en: 'Retry');
  String get cancel => tr(fr: 'Annuler', en: 'Cancel');
  String get save => tr(fr: 'Enregistrer', en: 'Save');
  String get delete => tr(fr: 'Supprimer', en: 'Delete');
  String get edit => tr(fr: 'Modifier', en: 'Edit');
  String get add => tr(fr: 'Ajouter', en: 'Add');
  String get back => tr(fr: 'Retour', en: 'Back');
  String get loading => tr(fr: 'Chargement…', en: 'Loading...');
  String get email => tr(fr: 'Email', en: 'Email');
  String get password => tr(fr: 'Mot de passe', en: 'Password');
  String get documents => tr(fr: 'Documents', en: 'Documents');
  String get settings => tr(fr: 'Paramètres', en: 'Settings');
  String get language => tr(fr: 'Langue', en: 'Language');
  String get english => tr(fr: 'Anglais', en: 'English');
  String get logout => tr(fr: 'Déconnexion', en: 'Logout');
  String get cancelAction => tr(fr: 'Annuler', en: 'Cancel');
  String get doctor => tr(fr: 'Médecin', en: 'Doctor');
  String get patient => tr(fr: 'Patient', en: 'Patient');
  String get search => tr(fr: 'Recherche', en: 'Search');
  String get messages => tr(fr: 'Messages', en: 'Messages');
  String get calendar => tr(fr: 'Calendrier', en: 'Calendar');
  String get schedule => tr(fr: 'Programme', en: 'Schedule');
  String get lists => tr(fr: 'Liste', en: 'Lists');
  String get upcoming => tr(fr: 'À venir', en: 'Upcoming');
  String get past => tr(fr: 'Passés', en: 'Past');
  String get cancelled => tr(fr: 'Annulés', en: 'Cancelled');
  String get total => tr(fr: 'Total', en: 'Total');
  String get active => tr(fr: 'Actifs', en: 'Active');
  String get inactive => tr(fr: 'Inactifs', en: 'Inactive');
  String get all => tr(fr: 'Tous', en: 'All');
  String get myDocuments => tr(fr: 'Mes documents', en: 'My Documents');
  String get yourDocuments => tr(fr: 'Vos documents', en: 'Your Documents');
  String get uploading => tr(fr: 'Téléversement…', en: 'Uploading...');
  String get uploadingTitle => tr(fr: 'Téléversement', en: 'Uploading');
  String get uploadDocuments =>
      tr(fr: 'Téléverser des documents', en: 'Upload Documents');
  String get noDocumentsYet =>
      tr(fr: 'Aucun document pour le moment', en: 'No documents yet');
  String get uploadFirstDocument => tr(
        fr: 'Téléversez votre premier document pour commencer',
        en: 'Upload your first document to get started',
      );
  String get deleteDocumentTitle =>
      tr(fr: 'Supprimer le document', en: 'Delete Document');
  String get documentDeleted =>
      tr(fr: 'Document supprimé', en: 'Document deleted');
  String confirmUploadFailed(String message) => tr(
        fr: 'Échec de la confirmation du téléversement : $message',
        en: 'Upload confirmation failed: $message',
      );
  String get noAvailableSlots => tr(
        fr: 'Aucun créneau disponible pour cette date.',
        en: 'No available slots for this date.',
      );
  String get bookAppointment =>
      tr(fr: 'Prendre rendez-vous', en: 'Book an appointment');
  String get confirmAppointment =>
      tr(fr: 'Confirmer le rendez-vous', en: 'Confirm appointment');
  String get addMedication =>
      tr(fr: 'Ajouter un médicament', en: 'Add medication');
  String get addMedicationsWithSchedules => tr(
      fr: 'Ajoutez des médicaments avec des horaires',
      en: 'Add medications with schedules');
  String get addMedicationShort =>
      tr(fr: 'Ajouter un médicament', en: 'Add medication');
  String get addToPillbox =>
      tr(fr: 'Ajouter au pilulier', en: 'Add to pillbox');
  String get medicationPlan =>
      tr(fr: 'Plan de médicaments', en: 'Medication Plan');
  String get medicationNotFound =>
      tr(fr: 'Médicament introuvable', en: 'Medication not found');
  String get instructions => tr(fr: 'Instructions', en: 'Instructions');
  String get quantity => tr(fr: 'Quantité', en: 'Quantity');
  String get unit => tr(fr: 'Unité', en: 'Unit');
  String get notesOptional =>
      tr(fr: 'Notes (optionnel)', en: 'Notes (optional)');
  String get momentOfDay => tr(fr: 'Moment de la journée', en: 'Time of day');
  String get timeOfIntake => tr(fr: 'Heure de prise', en: 'Intake time');
  String get addSchedule => tr(fr: 'Ajouter un horaire', en: 'Add schedule');
  String get modifySchedule =>
      tr(fr: 'Modifier l\'horaire', en: 'Edit schedule');
  String get scheduleTimes => tr(fr: 'Horaires de prise', en: 'Intake times');
  String get actions => tr(fr: 'Actions', en: 'Actions');
  String get frequency => tr(fr: 'Fréquence', en: 'Frequency');
  String get start => tr(fr: 'Début', en: 'Start');
  String get end => tr(fr: 'Fin', en: 'End');
  String get description => tr(fr: 'Description', en: 'Description');
  String get markAsTaken => tr(fr: 'Marquer comme pris', en: 'Mark as taken');
  String get skip => tr(fr: 'Ignorer', en: 'Skip');
  String get approveAll => tr(fr: 'Tout approuver', en: 'Approve all');
  String get rejectAll => tr(fr: 'Tout refuser', en: 'Reject all');
  String get soonAvailable =>
      tr(fr: 'Bientôt disponible…', en: 'Coming soon...');
  String get chooseSpecialty =>
      tr(fr: 'Choisir une spécialité', en: 'Choose a specialty');
  String get specialties => tr(fr: 'Spécialités', en: 'Specialties');
  String get askDocAi =>
      tr(fr: 'Posez votre question à DocAI', en: 'Ask DocAI a question');
  String get docAiAssistant => tr(fr: 'Assistant DocAI', en: 'DocAI Assistant');
  String get viewAll => tr(fr: 'Voir tout', en: 'View All');
  String get history => tr(fr: 'Historique', en: 'History');
  String get recentActivity =>
      tr(fr: 'Activité récente', en: 'Recent Activity');
  String get proMember => tr(fr: 'Membre Pro', en: 'Pro member');
  String get todayIntakes => tr(fr: 'Prises du jour', en: 'Today\'s intakes');
  String todayIntakeProgress(int taken, int total) =>
      tr(fr: '$taken/$total prises effectuées', en: '$taken/$total taken');
  String get noIntakesToday => tr(
      fr: 'Aucune prise prévue aujourd\'hui', en: 'No intakes scheduled today');
  String get startChatDocAi =>
      tr(fr: 'Commencer un chat avec DocAI', en: 'Start a chat with DocAI');
  String intakeAlreadyTaken(String medicationName) =>
      tr(fr: 'Prise déjà effectuée', en: 'Already taken');
  String intakeSkipped(String medicationName) =>
      tr(fr: 'Prise ignorée', en: 'Skipped');
  String markedAsTaken(String medicationName) => tr(
      fr: '$medicationName marqué comme pris !',
      en: '$medicationName marked as taken!');
  String skippedMedication(String medicationName) =>
      tr(fr: '$medicationName ignoré', en: '$medicationName skipped');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales
      .any((supported) => supported.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
