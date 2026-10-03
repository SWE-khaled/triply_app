import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/mock/mock_guide_profile.dart';
import '../model/guide_profile.dart';
import 'guide_profile_state.dart';

/// Guide profile display data (mock -> Model). Static in this phase.
class GuideProfileCubit extends Cubit<GuideProfileState> {
  GuideProfileCubit()
    : super(
        GuideProfileState(profile: GuideProfile.fromJson(mockGuideProfileJson)),
      );
}
