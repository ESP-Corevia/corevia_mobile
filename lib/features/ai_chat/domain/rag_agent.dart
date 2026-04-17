class RagAgent {
  final String id;
  final String label;

  const RagAgent({
    required this.id,
    required this.label,
  });
}

class RagAgents {
  static const medecinGeneraliste = RagAgent(
    id: 'medecin_generaliste',
    label: 'Médecin généraliste',
  );

  static const dermatologue = RagAgent(
    id: 'dermatologue',
    label: 'Dermatologue',
  );

  static const nutritionniste = RagAgent(
    id: 'nutritionniste',
    label: 'Nutritionniste',
  );

  static const psychologue = RagAgent(
    id: 'psychologue',
    label: 'Psychologue',
  );

  static const all = <RagAgent>[
    medecinGeneraliste,
    dermatologue,
    nutritionniste,
    psychologue,
  ];

  static RagAgent byId(String id) {
    return all.firstWhere(
      (a) => a.id == id,
      orElse: () => medecinGeneraliste,
    );
  }
}
