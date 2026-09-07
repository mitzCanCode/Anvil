//
//  RequestHeadersEditor.swift
//  DevPoint
//

import SwiftUI

struct RequestHeadersEditor: View {
    @Binding var entries: [RequestHeader]
    
    var body: some View {
        Section {
            if !entries.isEmpty {
                
                HStack(spacing: 12) {
                    Text("Header name")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                    
                    
                    Text("Value")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .font(.title3)
                .foregroundStyle(.secondary)
            }
            
            ForEach($entries) { $entry in
                HStack(spacing: 12) {
                    TextField("Header name", text: $entry.key)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .frame(maxWidth: .infinity)
                    
                    Divider()
                    
                    TextField("Value", text: $entry.value)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .frame(maxWidth: .infinity)
                }
                .swipeActions(edge: .trailing) {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        entries.removeAll { $0.id == entry.id }
                    }
                    .tint(.red)
                }
            }
            
            Button {
                entries.append(RequestHeader())
            } label: {
                Label("Add Header", systemImage: "plus")
            }
        } header: {
            Text("Request Headers")
        } footer: {
            Text("Headers are sent with the request to the server. They can be used to provide additional information, such as content types, accepted formats, client information etc.")
        }
    }
}

#Preview {
    Form {
        RequestHeadersEditor(entries: .constant([
            RequestHeader(key: "Accept", value: "application/json"),
            RequestHeader(key: "X-Client-Version", value: "1.0")
        ]))
    }
}
