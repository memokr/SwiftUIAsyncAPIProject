//
//  ContentView.swift
//  SwiftUIAsyncAPIProject
//
//  Created by Guillermo Kramsky on 25/03/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var user: GitHubUser?
    @State private var username: String = ""
    @State private var showAlert = false
    @State private var errorType: GHError?
    @State private var searchText: String = ""
    
    
    var body: some View {
        
        ScrollView{
            VStack {
                
                TextField("Write a GitHub username", text: $searchText)
                    .padding()
                
                Button(action: {
                    username = searchText
                    getUserAsync()
                }) {
                    Text("Search")
                }
                .padding()
                
                
                AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                } placeholder: {
                    Circle()
                        .foregroundColor(.gray)
                }
                .frame(width: 200, height: 200)
                .padding()
                
                
                
                Text(user?.login ?? "Username")
                    .bold()
                    .font(.title3)
                    .padding()
                
                if user?.createdAt != nil {
                    
                    if let date = formatDateFromString(user?.createdAt ?? "") {
                        // Format date as desired
                        Text("Created at \(formatDate(date))")
                            .font(.title3)
                            .padding()
                    }
                    
                    
                    
                    
                }
                
                if user?.publicRepos != nil {
                    Text("Public repos: \(String(describing: user!.publicRepos))")
                        .padding()
                }
                
                Text(user?.bio ?? "user has no description")
                
                Spacer()
            }
            .padding()
            .task {
                do {
                    user = try await getUser()
                }
                catch GHError.invalidData {
                    print("Invalid Data")
                } catch GHError.invalidUrl{
                    print("Invalid Url")
                } catch GHError.invalidResponse{
                    print("Invalid Response")
                } catch {
                    print("Unexpected Error")
                }
            }
            .alert(isPresented: $showAlert) {
                switch errorType {
                case .invalidUrl:
                    return Alert(title: Text("Invalid URL"), message: Text("The URL is invalid."), dismissButton: .default(Text("OK")))
                case .invalidResponse:
                    return Alert(title: Text("Invalid Response"), message: Text("The response from the server is invalid."), dismissButton: .default(Text("OK")))
                case .invalidData:
                    return Alert(title: Text("Invalid Data"), message: Text("The data received from the server is invalid."), dismissButton: .default(Text("OK")))
                case .none:
                    return Alert(title: Text("Unknown Error"), message: Text("An unknown error occurred."), dismissButton: .default(Text("OK")))
                }
            }
        }
    }
    
    
    func getUserAsync() {
        Task {
            do {
                user = try await getUser()
            } catch GHError.invalidData {
                errorType = GHError.invalidData
                showAlert = true
            } catch GHError.invalidUrl{
                errorType = GHError.invalidUrl
                showAlert = true
            } catch GHError.invalidResponse{
                errorType = GHError.invalidResponse
                showAlert = true
            } catch {
                print("Unexpected Error")
            }
        }
    }
    
    func getUser() async throws -> GitHubUser {
        let endpoint = "https://api.github.com/users/\(username)"
        
        guard let url = URL(string: endpoint) else { throw GHError.invalidUrl }
        let (data, response) = try await URLSession.shared.data(from: url)
        
        
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        } catch {
            throw GHError.invalidData
        }
    }
    
    func formatDateFromString(_ dateString: String) -> Date? {
          let dateFormatter = ISO8601DateFormatter()
          dateFormatter.formatOptions = [.withInternetDateTime]
          return dateFormatter.date(from: dateString)
      }
    
    func formatDate(_ date: Date) -> String {
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "MMM dd, yyyy"
         return dateFormatter.string(from: date)
     }
}

#Preview {
    ContentView()
}
