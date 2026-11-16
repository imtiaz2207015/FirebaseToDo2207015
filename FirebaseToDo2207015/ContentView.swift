
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        if auth.user == nil {
            LoginView()
        } else {
            TaskListView()
        }
    }
}

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Todo App").font(.largeTitle)
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .textFieldStyle(.roundedBorder)
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            Button("Login") { auth.login(email: email, password: password) }
            Button("Register") { auth.register(email: email, password: password) }
            Text(auth.errorMessage).foregroundColor(.red).font(.caption)
        }
        .padding()
    }
}

struct TaskListView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject var vm = TaskViewModel()
    @State private var showAdd = false
    @State private var editing: TaskItem?

    var uid: String { auth.user?.uid ?? "" }

    var body: some View {
        NavigationView {
            List {
                ForEach(vm.tasks) { t in
                    VStack(alignment: .leading) {
                        Text(t.title).font(.headline)
                        Text(t.description).font(.subheadline)
                    }
                    .onTapGesture { editing = t }
                }
                .onDelete { idx in
                    idx.forEach { vm.delete(uid: uid, task: vm.tasks[$0]) }
                }
            }
            .navigationTitle("My Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Logout") { vm.stop(); auth.logout() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") { showAdd = true }
                }
            }
            .sheet(isPresented: $showAdd) {
                TaskForm(task: nil) { title, desc in
                    vm.add(uid: uid, title: title, desc: desc)
                }
            }
            .sheet(item: $editing) { t in
                TaskForm(task: t) { title, desc in
                    var u = t
                    u.title = title
                    u.description = desc
                    vm.update(uid: uid, task: u)
                }
            }
        }
        .onAppear { vm.start(uid: uid) }
    }
}

struct TaskForm: View {
    @Environment(\.dismiss) var dismiss
    @State var title: String
    @State var desc: String
    var onSave: (String, String) -> Void

    init(task: TaskItem?, onSave: @escaping (String, String) -> Void) {
        _title = State(initialValue: task?.title ?? "")
        _desc = State(initialValue: task?.description ?? "")
        self.onSave = onSave
    }

    var body: some View {
        VStack(spacing: 16) {
            TextField("Title", text: $title).textFieldStyle(.roundedBorder)
            TextField("Description", text: $desc).textFieldStyle(.roundedBorder)
            Button("Save") { onSave(title, desc); dismiss() }
        }
        .padding()
    }
}
