import '../models/service_request_model.dart';
import '../models/mechanic_model.dart';
import '../models/message_model.dart';
import '../models/review_model.dart';

class FirestoreService {
  // ─── Request Methods ──────────────────────────────────────────────────────

  Future<ServiceRequestModel?> getActiveRequest(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Return null to indicate no active request by default
    return null;
  }

  Future<ServiceRequestModel> createRequest(ServiceRequestModel request) async {
    await Future.delayed(const Duration(seconds: 1));
    // Simulate creating request and assigning a mechanic
    return request.copyWith(
      status: 'pending',
      mechanicId: MechanicModel.mock.id,
    );
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Stub: in real app, update Firestore
  }

  Future<List<ServiceRequestModel>> getRequestHistory(String userId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return ServiceRequestModel.mockHistory;
  }

  Future<MechanicModel?> getMechanicById(String mechanicId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (mechanicId == MechanicModel.mock.id) {
      return MechanicModel.mock;
    }
    return null;
  }

  Future<void> sendMessage(MessageModel message) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Stub: in real app, write to Firestore
  }

  Future<List<MessageModel>> getMessages(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MessageModel.mockMessages('user_mock_001', 'mechanic_mock_001');
  }

  Future<void> submitReview(ReviewModel review) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Stub: in real app, write to Firestore
  }

  Future<void> cancelRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Stub: update status to cancelled
  }
}
