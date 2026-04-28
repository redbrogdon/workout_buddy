import 'package:genui/genui.dart';
import 'reps_card.dart';
import 'timer_card.dart';
import 'workout_card.dart';
import 'exercise_tile.dart';
import 'session_summary.dart';
import 'report_widgets.dart';

import 'ai_proposal_card.dart';

final workoutBuddyCatalog = BasicCatalogItems.asCatalog().copyWith(
  newItems: [
    aiCoachProposalCard,
    workoutCard,
    repsCard,
    timerCard,
    exerciseTile,
    sessionSummary,
    barChart,
    summaryCard,
  ],
);
