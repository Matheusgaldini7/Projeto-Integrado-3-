import '../models/Ambiente.dart';

const List<Ambiente> ambientesMock = [
  Ambiente(
    id: 'h15', nome: 'Bloco H15',
    descricao: 'Início do jogo. Salas de computação e laboratórios no subsolo.\nApós o desmaio, o local se transforma em espaço vazio.',
    latitude: -22.8361, longitude: -47.0547, raioMetros: 30,
    ordem: 1, chefe: 'maligno',
    itemRecompensa: 'Caneta da Aprovação', skillRecompensa: 'Argumentação Final',
  ),
  Ambiente(
    id: 'politecnica', nome: 'Politécnica (CEATEC)',
    descricao: 'Laboratório de Engenharia com quadro de Matemática.\nClima futurista e hostil.',
    latitude: -22.8357, longitude: -47.0559, raioMetros: 30,
    ordem: 2, chefe: 'derivador',
    itemRecompensa: 'Calculadora', skillRecompensa: 'Raciocínio Lógico',
  ),
  Ambiente(
    id: 'refeitorio', nome: 'Refeitório',
    descricao: 'Zona segura. Sem inimigos.\nRecupere HP antes dos próximos desafios.',
    latitude: -22.8353, longitude: -47.0553, raioMetros: 25,
    ordem: 0, chefe: '',
    itemRecompensa: 'Café Energético', skillRecompensa: '',
  ),
  Ambiente(
    id: 'h06', nome: 'Bloco H06',
    descricao: 'Local remoto e hostil. Telas azuis de logon.\nAr-condicionado ensurdecedor.',
    latitude: -22.8349, longitude: -47.0561, raioMetros: 30,
    ordem: 3, chefe: 'compilador',
    itemRecompensa: 'IDE', skillRecompensa: 'Clean Code',
  ),
  Ambiente(
    id: 'auditorio', nome: 'Auditório Principal',
    descricao: 'Palco da Aprovação. Ambiente vasto e escuro.\nConfrontou final com o Reitor das Sombras.',
    latitude: -22.8345, longitude: -47.0555, raioMetros: 35,
    ordem: 4, chefe: 'reitor',
    itemRecompensa: 'Diploma', skillRecompensa: 'Resiliência Acadêmica',
  ),
];
