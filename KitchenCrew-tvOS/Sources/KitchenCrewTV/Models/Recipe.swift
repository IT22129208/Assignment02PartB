import Foundation

public enum CameraAngle: String, CaseIterable, Identifiable, Codable {
    case wideChef = "Wide Chef Angle"
    case macroPan = "Macro Pan & Sizzle"
    case overheadPlating = "Overhead Plating"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .wideChef: return "person.crop.rectangle.fill"
        case .macroPan: return "flame.fill"
        case .overheadPlating: return "camera.metering.spot"
        }
    }
}

public enum StationRole: String, CaseIterable, Identifiable, Codable {
    case prep = "Prep & Mise-en-place"
    case saute = "Sauté & Stovetop"
    case oven = "Oven & Roasting"
    case plating = "Assembly & Plating"
    
    public var id: String { rawValue }
    
    public var colorHex: String {
        switch self {
        case .prep: return "#38bdf8"     // Cyan/Sky
        case .saute: return "#f97316"    // Warm Amber/Orange
        case .oven: return "#ef4444"     // Crimson Red
        case .plating: return "#a855f7"  // Royal Violet
        }
    }
    
    public var icon: String {
        switch self {
        case .prep: return "knife.fill"
        case .saute: return "frying.pan.fill"
        case .oven: return "oven.fill"
        case .plating: return "fork.knife"
        }
    }
}

public struct Ingredient: Identifiable, Codable, Hashable {
    public let id: UUID
    public let name: String
    public let amount: Double
    public let unit: String
    public let station: StationRole
    public let substitutionOption: String?
    public let allergyWarning: String?
    public var isPrepped: Bool = false
    
    public init(id: UUID = UUID(), name: String, amount: Double, unit: String, station: StationRole, substitutionOption: String? = nil, allergyWarning: String? = nil, isPrepped: Bool = false) {
        self.id = id
        self.name = name
        self.amount = amount
        self.unit = unit
        self.station = station
        self.substitutionOption = substitutionOption
        self.allergyWarning = allergyWarning
        self.isPrepped = isPrepped
    }
}

public struct RecipeStep: Identifiable, Codable, Hashable {
    public let id: Int
    public let title: String
    public let instruction: String
    public let assignedStation: StationRole
    public let recommendedAngle: CameraAngle
    public let durationSeconds: Int?
    public let requiresTimer: Bool
    public let chefTip: String?
    public let criticalWarning: String?
    public let dependsOnStepId: Int?
    public var isCompleted: Bool = false
    
    public init(
        id: Int,
        title: String,
        instruction: String,
        assignedStation: StationRole,
        recommendedAngle: CameraAngle = .wideChef,
        durationSeconds: Int? = nil,
        requiresTimer: Bool = false,
        chefTip: String? = nil,
        criticalWarning: String? = nil,
        dependsOnStepId: Int? = nil,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.instruction = instruction
        self.assignedStation = assignedStation
        self.recommendedAngle = recommendedAngle
        self.durationSeconds = durationSeconds
        self.requiresTimer = requiresTimer
        self.chefTip = chefTip
        self.criticalWarning = criticalWarning
        self.dependsOnStepId = dependsOnStepId
        self.isCompleted = isCompleted
    }
}

public struct Recipe: Identifiable, Codable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let masterChef: String
    public let difficulty: String
    public let totalMinutes: Int
    public let heroImageName: String
    public let streamUrls: [CameraAngle: URL]
    public let ingredients: [Ingredient]
    public var steps: [RecipeStep]
    
    public init(
        id: String,
        title: String,
        subtitle: String,
        masterChef: String,
        difficulty: String,
        totalMinutes: Int,
        heroImageName: String,
        streamUrls: [CameraAngle: URL],
        ingredients: [Ingredient],
        steps: [RecipeStep]
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.masterChef = masterChef
        self.difficulty = difficulty
        self.totalMinutes = totalMinutes
        self.heroImageName = heroImageName
        self.streamUrls = streamUrls
        self.ingredients = ingredients
        self.steps = steps
    }
    
    public static let sampleScallops = Recipe(
        id: "michelin-scallops-01",
        title: "Pan-Seared Day-Boat Scallops",
        subtitle: "Silky Cauliflower Mousseline & Crispy Pancetta Herb Brown Butter",
        masterChef: "Chef Laurent Dumas (3★ Michelin)",
        difficulty: "Intermediate",
        totalMinutes: 28,
        heroImageName: "plated_dish",
        streamUrls: [
            .wideChef: URL(string: "https://kitchencrew.cdn.stream/scallops/wide.m3u8")!,
            .macroPan: URL(string: "https://kitchencrew.cdn.stream/scallops/macro.m3u8")!,
            .overheadPlating: URL(string: "https://kitchencrew.cdn.stream/scallops/overhead.m3u8")!
        ],
        ingredients: [
            Ingredient(name: "Fresh Jumbo Sea Scallops", amount: 12, unit: "pcs", station: .saute, substitutionOption: "King Oyster Mushroom rounds (vegan)", allergyWarning: "Molluscan Shellfish"),
            Ingredient(name: "French Shallots", amount: 2, unit: "whole", station: .prep, substitutionOption: "Red onion finely minced"),
            Ingredient(name: "Fresh Thyme Sprigs", amount: 4, unit: "sprigs", station: .prep),
            Ingredient(name: "Cauliflower Florets", amount: 1, unit: "head", station: .prep),
            Ingredient(name: "European Cultured Butter", amount: 4, unit: "tbsp", station: .saute, substitutionOption: "Extra virgin olive oil + plant butter"),
            Ingredient(name: "Pancetta Lardons", amount: 100, unit: "g", station: .saute, substitutionOption: "Smoked shiitake bacon"),
            Ingredient(name: "Heavy Cream", amount: 80, unit: "ml", station: .prep, substitutionOption: "Oat cooking cream or cashew milk")
        ],
        steps: [
            RecipeStep(
                id: 1,
                title: "Mise en Place & Scallop Preparation",
                instruction: "Chef Alex: Pat scallops completely dry with paper towels. Season with kosher salt. Chef Sarah: Dice shallots and strip thyme leaves.",
                assignedStation: .prep,
                recommendedAngle: .wideChef,
                durationSeconds: 180,
                requiresTimer: false,
                chefTip: "Moisture is the enemy of a golden crust. Surface must be bone-dry."
            ),
            RecipeStep(
                id: 2,
                title: "Silky Cauliflower Puree Simmer",
                instruction: "Chef Alex: Steam cauliflower florets until fork-tender, then blend with heavy cream and butter until ultra-velvety.",
                assignedStation: .prep,
                recommendedAngle: .wideChef,
                durationSeconds: 420,
                requiresTimer: true,
                chefTip: "Blend while steaming hot for maximum emulsion smoothness."
            ),
            RecipeStep(
                id: 3,
                title: "Render Crispy Pancetta",
                instruction: "Chef Sarah: Heat stainless copper pan to medium-high. Render pancetta until golden and crunchy. Transfer lardons to towel, reserving oil.",
                assignedStation: .saute,
                recommendedAngle: .macroPan,
                durationSeconds: 240,
                requiresTimer: true,
                dependsOnStepId: 1
            ),
            RecipeStep(
                id: 4,
                title: "Hard Sear: The 90-Second Sear",
                instruction: "Chef Sarah: Crank pan heat until smoking hot. Place scallops clockwise. Do not touch or shake pan for 90 seconds.",
                assignedStation: .saute,
                recommendedAngle: .macroPan,
                durationSeconds: 90,
                requiresTimer: true,
                criticalWarning: "Keep heat high! Moving the scallop tears the caramelized sear crust.",
                dependsOnStepId: 3
            ),
            RecipeStep(
                id: 5,
                title: "Aromatics & Butter Basting (Arrosé)",
                instruction: "Chef Sarah: Flip scallops. Drop 2 tbsp cold butter, shallots, and thyme. Tilt pan and spoon foaming brown butter continuously over scallops for 60 seconds.",
                assignedStation: .saute,
                recommendedAngle: .macroPan,
                durationSeconds: 60,
                requiresTimer: true,
                chefTip: "The foaming milk solids caramelize to produce rich hazelnut notes (beurre noisette)."
            ),
            RecipeStep(
                id: 6,
                title: "Synchronized Plating & Garnish",
                instruction: "Both Chefs: Chef Alex swooshes warm cauliflower puree across slate plates. Chef Sarah places 3 seared scallops atop puree, garnishes with crispy pancetta and chive oil.",
                assignedStation: .plating,
                recommendedAngle: .overheadPlating,
                durationSeconds: 120,
                requiresTimer: false,
                chefTip: "Serve immediately while plates and scallops retain high heat."
            )
        ]
    )
}
