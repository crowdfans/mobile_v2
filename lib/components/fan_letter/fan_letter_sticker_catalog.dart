/// Coleção de adesivos da Fan Letter (assets locais + mock Superfã).
class FanLetterStickerCollection {
  const FanLetterStickerCollection({
    required this.id,
    required this.title,
    required this.description,
    required this.assets,
  });

  final String id;
  final String title;
  final String description;
  final List<String> assets;
}

/// Catálogo alinhado aos prints (Festa no Ar / Capivibes + extras do app).
const fanLetterStickerCollections = [
  FanLetterStickerCollection(
    id: 'festa-no-ar',
    title: 'Festa no Ar',
    description:
        'Balões, velas e brilho de parabéns para cartas em clima de celebração.',
    assets: [
      'assets/Stickers/Birthday/Artboard 2@2x.png',
      'assets/Stickers/Birthday/Artboard 3@2x.png',
      'assets/Stickers/Birthday/Artboard 4@2x.png',
      'assets/Stickers/Birthday/Artboard 5@2x.png',
      'assets/Stickers/Birthday/Artboard 6@2x.png',
      'assets/Stickers/Birthday/Artboard 7@2x.png',
    ],
  ),
  FanLetterStickerCollection(
    id: 'capivibes',
    title: 'Capivibes',
    description:
        'Capivaras carismáticas em poses românticas, musicais e absurdamente simpáticas.',
    assets: [
      'assets/Stickers/Capybara/CapybaraCharacterSticker_bee.png',
      'assets/Stickers/Capybara/CapybaraCharacterSticker_coffee.png',
      'assets/Stickers/Capybara/CapybaraCharacterSticker_donut.png',
      'assets/Stickers/Capybara/CapybaraCharacterSticker_music.png',
      'assets/Stickers/Capybara/CapybaraCharacterSticker_romantic.png',
      'assets/Stickers/Capybara/CapybaraCharacterSticker_love.png',
    ],
  ),
  FanLetterStickerCollection(
    id: 'cute',
    title: 'Cute Stickers',
    description: 'Adesivos coloridos para deixar a carta mais leve.',
    assets: [
      'assets/Stickers/cute stickers/Sticker-01.png',
      'assets/Stickers/cute stickers/Sticker-02.png',
      'assets/Stickers/cute stickers/Sticker-03.png',
      'assets/Stickers/cute stickers/Sticker-04.png',
      'assets/Stickers/cute stickers/Sticker-05.png',
      'assets/Stickers/cute stickers/Sticker-06.png',
    ],
  ),
  FanLetterStickerCollection(
    id: 'love-it',
    title: 'Love it',
    description: 'Corações e carinho para cartas mais afetuosas.',
    assets: [
      'assets/Stickers/Love it/Sticker-01.png',
      'assets/Stickers/Love it/Sticker-02.png',
      'assets/Stickers/Love it/Sticker-03.png',
      'assets/Stickers/Love it/Sticker-04.png',
      'assets/Stickers/Love it/Sticker-05.png',
      'assets/Stickers/Love it/Sticker-06.png',
    ],
  ),
];
