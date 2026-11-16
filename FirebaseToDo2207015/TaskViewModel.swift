
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct TaskItem: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
}

class TaskViewModel: ObservableObject {
    @Published var tasks: [TaskItem] = []
    private var listener: ListenerRegistration?
    private let db = Firestore.firestore()

    private func col(_ uid: String) -> CollectionReference {
        db.collection("users").document(uid).collection("tasks")
    }

    func start(uid: String) {
        listener?.remove()
        listener = col(uid).addSnapshotListener { snap, _ in
            self.tasks = snap?.documents.compactMap { try? $0.data(as: TaskItem.self) } ?? []
        }
    }

    func stop() {
        listener?.remove()
        tasks = []
    }

    func add(uid: String, title: String, desc: String) {
        try? col(uid).addDocument(from: TaskItem(title: title, description: desc))
    }

    func update(uid: String, task: TaskItem) {
        guard let id = task.id else { return }
        try? col(uid).document(id).setData(from: task)
    }

    func delete(uid: String, task: TaskItem) {
        guard let id = task.id else { return }
        col(uid).document(id).delete()
    }
}
