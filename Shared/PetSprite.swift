import SwiftUI

enum PetSprites {
    static let legs0 = ["..B.B...B.B.", "..B.B...B.B."]
    static let legs1 = ["...B.B.B.B..", "...B.B.B.B.."]

    static let cat = [
        "............",
        "........B.B.",
        "........BBBB",
        "B.......BEBE",
        ".B......BBBP",
        "..BBBBBBBBB.",
        "..BBBBBBBB..",
        "..BBBBBBBB..",
    ]
    static let dog = [
        "............",
        "........BBB.",
        ".......DBEBB",
        "B......DBBBE",
        ".B......BBB.",
        "..BBBBBBBBB.",
        "..BBBBBBBB..",
        "..BBBBBBBB..",
    ]
    static let bunny = [
        ".........B.B",
        ".........B.B",
        ".........BBB",
        "........BBEB",
        "........BBBP",
        "..BBBBBBBBB.",
        ".WBBBBBBBB..",
        "..BBBBBBBB..",
    ]

    static func rows(kind: String, frame: Int) -> [String] {
        let body: [String]
        switch kind {
        case "dog": body = dog
        case "bunny": body = bunny
        default: body = cat
        }
        return body + (frame == 0 ? legs0 : legs1)
    }

    static func color(kind: String, char: Character) -> Color? {
        switch char {
        case "E": return Color(red: 0.08, green: 0.08, blue: 0.1)
        case "P": return Color(red: 1.0, green: 0.55, blue: 0.7)
        case "W": return .white
        case "D": return Color(red: 0.35, green: 0.22, blue: 0.12)
        case "B":
            switch kind {
            case "dog": return Color(red: 0.72, green: 0.48, blue: 0.28)
            case "bunny": return Color(red: 0.88, green: 0.88, blue: 0.92)
            default: return Color(red: 1.0, green: 0.6, blue: 0.2)
            }
        default: return nil
        }
    }
}

struct PetSpriteView: View {
    let kind: String
    let frame: Int

    var body: some View {
        Canvas { ctx, size in
            let rows = PetSprites.rows(kind: kind, frame: frame)
            let h = rows.count
            let w = rows.map { $0.count }.max() ?? 1
            let px = min(size.width / CGFloat(w), size.height / CGFloat(h))
            let ox = (size.width - px * CGFloat(w)) / 2
            let oy = (size.height - px * CGFloat(h)) / 2
            for (y, row) in rows.enumerated() {
                for (x, ch) in row.enumerated() {
                    guard let c = PetSprites.color(kind: kind, char: ch) else { continue }
                    let rect = CGRect(x: ox + CGFloat(x) * px, y: oy + CGFloat(y) * px,
                                      width: px + 0.5, height: px + 0.5)
                    ctx.fill(Path(rect), with: .color(c))
                }
            }
        }
    }
}

struct PetWalkStrip: View {
    let kind: String
    let state: PetAttributes.ContentState
    var petWidth: CGFloat = 44
    var petHeight: CGFloat = 36

    var body: some View {
        GeometryReader { geo in
            PetSpriteView(kind: kind, frame: state.frame)
                .frame(width: petWidth, height: petHeight)
                .scaleEffect(x: state.facingRight ? 1 : -1, y: 1)
                .offset(x: max(0, geo.size.width - petWidth) * CGFloat(state.position),
                        y: max(0, geo.size.height - petHeight) / 2)
        }
    }
}
