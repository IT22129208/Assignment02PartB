// KitchenCrew Recipe & Station Data Store
window.KITCHEN_DATA = {
  recipe: {
    id: "michelin-scallops-01",
    title: "Pan-Seared Day-Boat Scallops",
    subtitle: "Silky Cauliflower Mousseline & Crispy Pancetta Herb Brown Butter",
    masterChef: "Chef Laurent Dumas (3★ Michelin)",
    difficulty: "Intermediate",
    totalMinutes: 28,
    servingSize: 2,
    angles: {
      wide: {
        label: "Chef Island (Wide)",
        image: "assets/chef_wide.jpg",
        description: "Full chef posture, knife safety, and overview of all cooking stations."
      },
      macro: {
        label: "Pan & Sizzle (Macro)",
        image: "assets/pan_macro.jpg",
        description: "Macro high-definition angle on the copper skillet, butter foam, and Maillard crust."
      },
      plating: {
        label: "Overhead Plating",
        image: "assets/plated_dish.jpg",
        description: "Top-down bird's-eye view for delicate spoon swiping and microgreen placement."
      }
    },
    ingredients: [
      { name: "Fresh Jumbo Sea Scallops", amount: 12, unit: "pcs", station: "saute", sub: "King Oyster Mushroom medallions (vegan)" },
      { name: "French Shallots", amount: 2, unit: "whole", station: "prep", sub: "Red onion finely minced" },
      { name: "Fresh Thyme Sprigs", amount: 4, unit: "sprigs", station: "prep", sub: "Fresh rosemary or tarragon" },
      { name: "Cauliflower Florets", amount: 1, unit: "head", station: "prep", sub: "Parsnip or celery root" },
      { name: "European Cultured Butter", amount: 4, unit: "tbsp", station: "saute", sub: "Cultured plant butter / EVOO" },
      { name: "Pancetta Lardons", amount: 100, unit: "g", station: "saute", sub: "Smoked shiitake mushroom bacon" },
      { name: "Heavy Cream", amount: 80, unit: "ml", station: "prep", sub: "Cashew cream or oat cooking cream" }
    ],
    steps: [
      {
        id: 1,
        title: "Mise en Place & Scallop Preparation",
        stationRole: "prep",
        stationName: "Prep Station (Chef Alex)",
        stationColor: "#38bdf8",
        recommendedAngle: "wide",
        durationSeconds: 180,
        instruction: "Chef Alex: Pat sea scallops completely dry on both sides with absorbent towels. Season generously with sea salt. Chef Sarah: Brunoise dice French shallots and strip fresh thyme leaves.",
        chefTip: "Moisture prevents the Maillard reaction. Scallops must be bone-dry for a glassy golden crust.",
        warning: null,
        timerNeeded: false,
        timerSeconds: 0
      },
      {
        id: 2,
        title: "Silky Cauliflower Mousseline Simmer",
        stationRole: "prep",
        stationName: "Prep Station (Chef Alex)",
        stationColor: "#38bdf8",
        recommendedAngle: "wide",
        durationSeconds: 420,
        instruction: "Chef Alex: Steam cauliflower florets in heavy-bottom pot until fork-tender. Puree in high-speed blender with warm cream and 2 tbsp butter until glossy.",
        chefTip: "Blend while steaming hot. The heat ensures emulsified silky texture without graininess.",
        warning: null,
        timerNeeded: true,
        timerSeconds: 420,
        timerLabel: "Cauliflower Steam"
      },
      {
        id: 3,
        title: "Render Crispy Pancetta Lardons",
        stationRole: "saute",
        stationName: "Sauté Station (Chef Sarah)",
        stationColor: "#f97316",
        recommendedAngle: "macro",
        durationSeconds: 240,
        instruction: "Chef Sarah: Set copper skillet over medium flame. Render diced pancetta until deep amber and crispy. Remove lardons with slotted spoon, leaving fragrant rendered pork fat in pan.",
        chefTip: "Start pancetta in a cold or medium pan to slowly render fat before browning.",
        warning: null,
        timerNeeded: true,
        timerSeconds: 240,
        timerLabel: "Pancetta Render"
      },
      {
        id: 4,
        title: "The 90-Second High-Heat Sear",
        stationRole: "saute",
        stationName: "Sauté Station (Chef Sarah)",
        stationColor: "#f97316",
        recommendedAngle: "macro",
        durationSeconds: 90,
        instruction: "Chef Sarah: Increase pan heat until oil reaches faint shimmering smoke. Place scallops clockwise starting at 12 o'clock. Sear untouched for precisely 90 seconds without shifting.",
        chefTip: "Clockwise placement ensures you flip them in the exact order they entered the heat.",
        warning: "CRITICAL: Do NOT move or shake the pan! Premature movement tears the delicate caramelized sear crust.",
        timerNeeded: true,
        timerSeconds: 90,
        timerLabel: "Scallop Hard Sear"
      },
      {
        id: 5,
        title: "Aromatics & Foaming Butter Basting (Arrosé)",
        stationRole: "saute",
        stationName: "Sauté Station (Chef Sarah)",
        stationColor: "#f97316",
        recommendedAngle: "macro",
        durationSeconds: 60,
        instruction: "Chef Sarah: Flip scallops gently. Add cold cubed butter, diced shallots, and fresh thyme. Tilt skillet toward you and continuously spoon foaming hazelnut butter over scallops for 60s.",
        chefTip: "Basting bathes the uncooked top surface in aromatic 280°F butter, cooking it through without overcooking.",
        warning: null,
        timerNeeded: true,
        timerSeconds: 60,
        timerLabel: "Butter Basting"
      },
      {
        id: 6,
        title: "Synchronized Final Plating & Service",
        stationRole: "plating",
        stationName: "Assembly Station (Both Chefs)",
        stationColor: "#a855f7",
        recommendedAngle: "plating",
        durationSeconds: 120,
        instruction: "Both Chefs: Chef Alex places a generous spoonful of silky cauliflower mousseline on warm slate plates, swiping with the back of a spoon. Chef Sarah tops with 3 golden scallops, pancetta, and microgreens.",
        chefTip: "Preheat serving plates to 140°F so delicate sea scallops remain piping hot at table.",
        warning: null,
        timerNeeded: false,
        timerSeconds: 0
      }
    ]
  },
  initialStations: [
    {
      id: "chef-alex",
      name: "Chef Alex",
      device: "iPad Pro 12.9\"",
      role: "prep",
      roleLabel: "Prep & Mise-en-place",
      color: "#38bdf8",
      tasks: [
        { id: "a1", text: "Pat scallops bone dry with towels", completed: true },
        { id: "a2", text: "Dice 2 French shallots brunoise", completed: true },
        { id: "a3", text: "Strip fresh thyme sprigs", completed: false },
        { id: "a4", text: "Steam & blend cauliflower puree", completed: false }
      ]
    },
    {
      id: "chef-sarah",
      name: "Chef Sarah",
      device: "iPhone 15 Pro",
      role: "saute",
      roleLabel: "Sauté & Stovetop",
      color: "#f97316",
      tasks: [
        { id: "s1", text: "Preheat copper skillet", completed: true },
        { id: "s2", text: "Render pancetta lardons until crisp", completed: false },
        { id: "s3", text: "Sear scallops (90s untouched)", completed: false },
        { id: "s4", text: "Foaming butter baste (Arrosé)", completed: false }
      ]
    }
  ]
};
