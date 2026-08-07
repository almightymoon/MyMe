window.MeMyData = {
  user: {
    name: "Emma",
    avatarInitials: "E",
  },

  lifeScore: 84,

  focus: {
    title: "Finish AI Research Paper",
    progress: 55,
  },

  weather: {
    temp: 22,
    condition: "Cloudy",
    icon: "cloud",
  },

  events: [
    { time: "10:00 AM", title: "Team Meeting", place: "Google Meet" },
    { time: "6:00 PM", title: "Gym Workout", place: "Fitness Center" },
  ],

  goals: [
    {
      id: "house",
      title: "Buy a House",
      subtitle: "PKR 150,000,000",
      progress: 7,
      status: "active",
      icon: "home",
      color: "#FF6B35",
    },
    {
      id: "emergency",
      title: "Build Emergency Fund",
      subtitle: "PKR 1,000,000",
      progress: 43,
      status: "active",
      icon: "shield",
      color: "#22C55E",
    },
    {
      id: "weight",
      title: "Lose 5 kg",
      subtitle: "Target: 67 kg",
      progress: 65,
      status: "active",
      icon: "fitness",
      color: "#3B82F6",
    },
    {
      id: "paper",
      title: "Publish Research Paper",
      subtitle: "Dec 15, 2026",
      progress: 20,
      status: "active",
      icon: "book",
      color: "#8B5CF6",
    },
    {
      id: "done-read",
      title: "Read 12 Books",
      subtitle: "Completed May 2026",
      progress: 100,
      status: "completed",
      icon: "book",
      color: "#F59E0B",
    },
  ],

  finance: {
    balance: 245000,
    income: 180000,
    expenses: 89000,
    categories: [
      { name: "Food", pct: 30, amt: 26700, color: "#E8501F" },
      { name: "Transport", pct: 20, amt: 17800, color: "#FF7A2F" },
      { name: "Shopping", pct: 15, amt: 13300, color: "#FFA51F" },
      { name: "Bills", pct: 15, amt: 13300, color: "#3B82F6" },
      { name: "Others", pct: 20, amt: 17900, color: "#9CA3AF" },
    ],
    /** Money you lent out — expecting to receive back */
    lent: [
      { name: "Sara Ahmed", note: "Trip expenses", amount: 25000, due: "Aug 20", status: "due-soon" },
      { name: "Ali Raza", note: "Laptop contribution", amount: 45000, due: "Sep 05", status: "upcoming" },
      { name: "Office lunch pool", note: "Shared meals", amount: 3200, due: "Aug 12", status: "overdue" },
    ],
    /** Loans / money you owe */
    loans: [
      { name: "HBL Personal Loan", note: "EMI · monthly", amount: 18500, due: "Aug 15", status: "due-soon" },
      { name: "Mom", note: "Family support", amount: 50000, due: "Oct 01", status: "upcoming" },
    ],
  },

  health: {
    heartRate: 95,
    steps: 7532,
    calories: 1650,
    sleep: "7h 45m",
    hrAvg: 95,
    hrMax: 240,
    hrMin: 60,
    stress: "Low",
    hrv: 92,
    weight: 72.5,
    heightCm: 175,
    heightLabel: "175 cm",
    bmi: 22.4,
    bodyFat: 18.6,
    bodyScore: 84,
    muscleMass: 62.5,
    boneMass: 2.8,
    bodyWater: 55.6,
    weightGoal: 65,
    weightProgress: 65,
    weightDelta: -0.5,
    bodyFatDelta: -1.2,
    waterCurrent: 1.6,
    waterGoal: 2,
    calorieGoal: 2000,
    macros: { protein: 45, carbs: 30, fat: 25, proteinG: 185, carbsG: 120, fatG: 55 },
    hrvBars: [40, 55, 48, 62, 70, 58, 45, 52, 68, 75, 60, 50, 42, 55, 72, 80, 65, 58, 48, 55, 70, 62, 50, 45],
    weightTrend: [74.2, 73.8, 73.5, 73.1, 72.8, 72.5],
    weightMonths: ["Mar", "Apr", "May", "Jun", "Jul", "Aug"],
    bodyScoreSpark: [62, 68, 70, 74, 78, 80, 84],
    muscleBalance: [
      { name: "Shoulders", status: "Good", pct: 72 },
      { name: "Chest", status: "Good", pct: 68 },
      { name: "Arms", status: "Good", pct: 70 },
      { name: "Abs", status: "Excellent", pct: 92 },
      { name: "Legs", status: "Good", pct: 74 },
    ],
    workoutFocus: {
      title: "Focus on core & lower body",
      subtitle: "Strengthen your core and build lower body power.",
      minutes: 22,
      level: "No equipment",
      tags: ["Core", "Fat Loss", "Endurance"],
      image: "assets/mod-health.png",
    },
    todayWorkout: [
      { id: "tw1", name: "Bicycle Crunches", detail: "3 × 15", tag: "Abs", selected: true },
      { id: "tw2", name: "Bodyweight Squat", detail: "3 × 12", tag: "Legs", selected: true },
      { id: "tw3", name: "Plank Hold", detail: "3 × 40s", tag: "Core", selected: false },
      { id: "tw4", name: "Walking Lunges", detail: "3 × 10", tag: "Legs", selected: false },
    ],
    exercises: [
      { id: "e1", name: "Mountain Climbers", muscles: "Abs · Core", level: "Bodyweight", equipment: "Bodyweight", detail: "3 × 20", sets: 3, reps: "20", rest: "30s", tag: "Abs", popular: 88 },
      { id: "e2", name: "Russian Twist", muscles: "Abs · Obliques", level: "Bodyweight", equipment: "Bodyweight", detail: "3 × 16", sets: 3, reps: "16", rest: "30s", tag: "Abs", popular: 82 },
      { id: "e3", name: "Push-Up", muscles: "Chest · Arms · Core", level: "Bodyweight", equipment: "Bodyweight", detail: "3 × 12", sets: 3, reps: "12", rest: "45s", tag: "Chest", popular: 96 },
      { id: "e4", name: "Reverse Lunge", muscles: "Legs · Glutes", level: "Bodyweight", equipment: "Bodyweight", detail: "3 × 12", sets: 3, reps: "12", rest: "40s", tag: "Legs", popular: 79 },
      { id: "e5", name: "Shoulder Tap Plank", muscles: "Arms · Core", level: "Bodyweight", equipment: "Bodyweight", detail: "3 × 20", sets: 3, reps: "20", rest: "30s", tag: "Arms", popular: 74 },
      { id: "e6", name: "Glute Bridge", muscles: "Legs · Glutes", level: "Bodyweight", equipment: "Bodyweight", detail: "3 × 15", sets: 3, reps: "15", rest: "35s", tag: "Legs", popular: 85 },
      { id: "e7", name: "Dead Bug", muscles: "Core · Abs", level: "Bodyweight", equipment: "Bodyweight", detail: "3 × 10", sets: 3, reps: "10", rest: "30s", tag: "Abs", popular: 71 },
      { id: "e8", name: "Wall Sit", muscles: "Legs · Quads", level: "Bodyweight", equipment: "Bodyweight", detail: "3 × 40s", sets: 3, reps: "40s", rest: "45s", tag: "Legs", popular: 68 },
      { id: "e9", name: "Dumbbell Row", muscles: "Back · Arms", level: "Dumbbell", equipment: "Dumbbell", detail: "3 × 10", sets: 3, reps: "10", rest: "60s", tag: "Back", popular: 90 },
      { id: "e10", name: "Overhead Press", muscles: "Shoulders · Arms", level: "Dumbbell", equipment: "Dumbbell", detail: "3 × 8", sets: 3, reps: "8", rest: "60s", tag: "Shoulders", popular: 84 },
      { id: "e11", name: "Barbell Squat", muscles: "Legs · Glutes", level: "Barbell", equipment: "Barbell", detail: "4 × 8", sets: 4, reps: "8", rest: "90s", tag: "Legs", popular: 94 },
      { id: "e12", name: "Kettlebell Swing", muscles: "Legs · Core", level: "Kettlebell", equipment: "Kettlebell", detail: "3 × 15", sets: 3, reps: "15", rest: "45s", tag: "Legs", popular: 87 },
    ],
    featuredProgram: {
      title: "Build Strength Anywhere",
      subtitle: "Effective exercises you can do at home or the gym.",
      count: 12,
      image: "assets/mod-health.png",
    },
  },

  meals: [
    {
      id: "breakfast",
      slot: "Breakfast",
      name: "Greek Yogurt · Berries",
      tags: "High protein • Low sugar",
      kcal: 320,
      time: "8:15 AM",
      img: "assets/meal.png?v=14",
      logged: true,
    },
    {
      id: "lunch",
      slot: "Lunch",
      name: "Grilled Chicken Salad",
      tags: "High protein • Balanced",
      kcal: 450,
      time: "1:30 PM",
      img: "assets/meal.png?v=14",
      logged: true,
    },
    {
      id: "dinner",
      slot: "Dinner",
      name: null,
      tags: "Add what you had for dinner",
      kcal: 0,
      logged: false,
    },
  ],

  nutritionExtras: {
    streak: 12,
    micros: [
      { name: "Fiber", pct: 68, color: "#34C759" },
      { name: "Iron", pct: 42, color: "#FF6A1A" },
      { name: "Calcium", pct: 75, color: "#3B82F6" },
    ],
    weekly: [1920, 1750, 2100, 1680, 1650, 1880, 1540],
    weekLabels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
    habits: [
      { id: "water", title: "Drink Water", value: "80%", sub: "1.6 / 2.0 L", tone: "blue" },
      { id: "veggies", title: "Eat Veggies", value: "2/3", sub: "servings", tone: "green" },
      { id: "move", title: "Move Daily", value: "6,200", sub: "steps", tone: "orange" },
      { id: "sleep", title: "Sleep Well", value: "7h 20m", sub: "avg", tone: "purple" },
    ],
  },

  calendar: {
    month: "August 2026",
    year: 2026,
    monthIndex: 7,
    selectedDay: 7,
    agenda: [
      {
        start: "10:00 AM",
        end: "11:00 AM",
        title: "Team Meeting",
        place: "Google Meet",
        color: "#34C759",
      },
      {
        start: "2:00 PM",
        end: "3:30 PM",
        title: "Research Work",
        place: "Focus Time",
        color: "#E8501F",
      },
      {
        start: "6:00 PM",
        end: "7:00 PM",
        title: "Gym Workout",
        place: "Fitness Center",
        color: "#34C759",
      },
    ],
  },

  outfits: {
    recommended: {
      title: "Business Casual",
      items: ["Blue Oxford Shirt", "Black Trousers", "White Sneakers", "Leather Watch"],
      tags: ["Meeting-ready", "Weather OK"],
    },
    alternatives: [
      { title: "Smart Casual", items: ["Navy Polo", "Chinos", "Loafers"] },
      { title: "Relaxed", items: ["Linen Shirt", "Jeans", "Trainers"] },
      { title: "Formal", items: ["White Shirt", "Suit Pants", "Oxfords"] },
    ],
  },

  /* Closet + Wear Decision — Wardrobe 2.0 */
  wardrobe: {
    weather: { temp: 22, label: "Cloudy", icon: "⛅" },
    event: { title: "Team Meeting", time: "10:00 AM", formality: 0.7 },
    style: "smart",
    styleTargets: {
      smart: 0.68,
      casual: 0.35,
      formal: 0.9,
      minimal: 0.5,
      date: 0.62,
      workout: 0.22,
    },
    pieces: [
      { id: "p1", name: "Blue Oxford Shirt", cat: "top", color: "#2F5AA8", colorName: "Blue", style: "smart", season: "all", weather: ["mild", "cool"], formality: 0.7, wearCount: 12, lastWorn: "Aug 2", pairsWith: ["p6", "p11", "p8"] },
      { id: "p2", name: "Navy Knit Polo", cat: "top", color: "#1F3A5F", colorName: "Navy", style: "smart", season: "all", weather: ["mild", "warm"], formality: 0.55, wearCount: 8, lastWorn: "Jul 28", pairsWith: ["p5", "p7"] },
      { id: "p3", name: "White Linen Shirt", cat: "top", color: "#F4F1EA", colorName: "White", style: "casual", season: "summer", weather: ["warm", "mild"], formality: 0.35, wearCount: 5, lastWorn: "Jul 20", pairsWith: ["p6", "p7"] },
      { id: "p4", name: "Charcoal Trousers", cat: "bottom", color: "#3A3A3C", colorName: "Charcoal", style: "smart", season: "all", weather: ["mild", "cool"], formality: 0.75, wearCount: 9, lastWorn: "Aug 1", pairsWith: ["p1", "p8"] },
      { id: "p5", name: "Sand Chinos", cat: "bottom", color: "#C4A574", colorName: "Sand", style: "smart", season: "all", weather: ["mild", "warm"], formality: 0.5, wearCount: 6, lastWorn: "Jul 25", pairsWith: ["p2", "p8"] },
      { id: "p6", name: "Dark Denim", cat: "bottom", color: "#1C2B4A", colorName: "Indigo", style: "casual", season: "all", weather: ["mild", "cool", "warm"], formality: 0.3, wearCount: 14, lastWorn: "Aug 4", pairsWith: ["p1", "p3", "p7"] },
      { id: "p7", name: "White Sneakers", cat: "shoes", color: "#F5F5F7", colorName: "White", style: "casual", season: "all", weather: ["mild", "warm"], formality: 0.4, wearCount: 18, lastWorn: "Aug 5", pairsWith: ["p3", "p6"] },
      { id: "p8", name: "Brown Loafers", cat: "shoes", color: "#8B5A2B", colorName: "Brown", style: "smart", season: "all", weather: ["mild", "cool"], formality: 0.7, wearCount: 7, lastWorn: "Aug 2", pairsWith: ["p1", "p4"] },
      { id: "p9", name: "Black Oxfords", cat: "shoes", color: "#1C1C1E", colorName: "Black", style: "formal", season: "all", weather: ["mild", "cool"], formality: 0.9, wearCount: 3, lastWorn: "Jun 12", pairsWith: ["p4", "p11"] },
      { id: "p10", name: "Olive Overshirt", cat: "layer", color: "#6B7C4C", colorName: "Olive", style: "casual", season: "fall", weather: ["cool", "mild"], formality: 0.4, wearCount: 2, lastWorn: "May 30", pairsWith: ["p6", "p7"] },
      { id: "p11", name: "Navy Blazer", cat: "layer", color: "#1A2A4A", colorName: "Navy", style: "formal", season: "all", weather: ["cool", "mild"], formality: 0.85, wearCount: 4, lastWorn: "Jul 10", pairsWith: ["p1", "p4", "p9"] },
      { id: "p12", name: "Leather Watch", cat: "accessory", color: "#5C4033", colorName: "Brown", style: "smart", season: "all", weather: ["mild", "cool", "warm"], formality: 0.6, wearCount: 20, lastWorn: "Aug 6", pairsWith: ["p1", "p8"] },
    ],
    looks: [
      { id: "l1", title: "Meeting Ready", pieceIds: ["p1", "p4", "p8", "p12"], note: "Saved for work days", style: "smart", fitScore: 96, date: "Aug 5", saved: true, worn: false, image: "assets/outfit-flat.png?v=13" },
    ],
    history: [
      { id: "h1", title: "Business Casual", pieceIds: ["p1", "p4", "p8"], style: "smart", fitScore: 94, date: "Aug 6", occasion: "Team Meeting", saved: false, worn: true, image: "assets/outfit-flat.png?v=13" },
      { id: "h2", title: "Weekend Easy", pieceIds: ["p3", "p6", "p7"], style: "casual", fitScore: 88, date: "Aug 3", occasion: "Brunch", saved: true, worn: true, image: "assets/outfit-alt1.png?v=13" },
      { id: "h3", title: "Sharp Evening", pieceIds: ["p1", "p4", "p9", "p11"], style: "formal", fitScore: 97, date: "Jul 28", occasion: "Dinner", saved: true, worn: true, image: "assets/outfit-alt2.png?v=13" },
    ],
    missing: [{ name: "Navy Chinos", reason: "Would complete more smart-casual looks", cat: "bottom" }],
    catMeta: {
      top: { label: "Tops", emoji: "👕" },
      bottom: { label: "Bottoms", emoji: "👖" },
      shoes: { label: "Shoes", emoji: "👟" },
      layer: { label: "Layers", emoji: "🧥" },
      accessory: { label: "Accessories", emoji: "⌚" },
    },
    styleImages: {
      smart: "assets/outfit-flat.png?v=13",
      casual: "assets/outfit-alt1.png?v=13",
      formal: "assets/outfit-alt2.png?v=13",
      minimal: "assets/outfit-flat.png?v=13",
      date: "assets/outfit-alt2.png?v=13",
      workout: "assets/outfit-alt1.png?v=13",
    },
  },

  coachReplies: {
    default:
      "Based on your goals and schedule, here's what I'd focus on today:\n\n1. Finish AI Research Paper (55% done — protect your 2–3:30 focus block)\n2. Gym Workout at 6:00 PM — keep your streak\n3. Save PKR 500 toward your emergency fund\n\nWant me to break any of these into smaller steps?",
    focus:
      "Protect your 2:00–3:30 Research Work block. You're at 55% on the paper — one solid session today keeps Dec 15 realistic. Gym at 6PM stays; don't skip hydration (1.6/2L).",
    afford:
      "Your monthly budget has room: ~PKR 42K left after typical spend. A PKR 1,250 lunch is fine. Skip impulse shopping this weekend — you spend ~32% more then.",
    workout:
      "Suggest today's workout: 40 min strength (upper body) + 10 min mobility. HRV is solid and stress is Low — good day to push intensity.",
    spend:
      "Food is 30% of expenses this month. Coffee and weekend dining are the biggest leaks. Cutting two cafe visits/week could free ~PKR 8–12K monthly.",
  },

  formatPKR(n) {
    return "PKR " + Number(n).toLocaleString("en-PK");
  },

  formatCompact(n) {
    if (n >= 1000) return Math.round(n / 1000) + "K";
    return String(n);
  },
};
