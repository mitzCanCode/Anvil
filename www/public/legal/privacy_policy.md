# Privacy Policy

**Last updated: [DATE]**

Anvil ("we", "us", or "our") is an independent iOS application developed by Dimitris Chatzigeorgiou ("the Developer"). We are committed to protecting your privacy. This Privacy Policy explains how information is collected, used, and protected when you use the Anvil mobile application (the "App" or "Service").

This Privacy Policy applies only to the Anvil iOS application. Anvil does not operate a companion website, and there is no user account system operated by the Developer.

By downloading or using the App, you acknowledge that you have read and understood this Privacy Policy.

## Definitions
- **App / Service:** The Anvil iOS mobile application.
- **Developer, we, us, our:** Dimitris Chatzigeorgiou, the individual developer of Anvil.
- **User, you:** The person using the Anvil application.
- **Device:** The iPhone or iPad on which the App is installed.
- **GitHub Personal Access Token (PAT):** An authentication credential you may optionally generate on GitHub and enter into the App to connect your GitHub account.
- **Checkpoint:** A website or API endpoint that you configure the App to monitor.

## Summary
Anvil is a local, on-device developer utility. The App does not have a backend server, does not require you to create an account with us, and does not collect, transmit, or store your personal data on any servers operated by the Developer. All data you enter into the App — including monitored URLs, GitHub tokens, and app settings — stays on your device, with the following exceptions:
- If you connect a GitHub account, your GitHub token is used to communicate **directly** with GitHub's own servers (`api.github.com`), never with servers operated by the Developer.
- If you configure the App to monitor a website or API ("Checkpoints"), the App sends network requests **directly** to the URLs you specify, in order to check their status, in the same way any web browser would.

## What Information Do We Collect?
We (the Developer) do not operate any backend, database, or analytics service for Anvil. We do not collect, receive, or have access to any of the information described below — it is processed and stored entirely on your device.

### GitHub Personal Access Token and Profile Data
If you choose to connect a GitHub account:
- You provide a GitHub Personal Access Token, which is stored securely in your device's Keychain (`kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`), protected by iOS's built-in encryption. It is never transmitted anywhere other than directly to GitHub's API.
- The App uses this token to make requests directly to GitHub's API (`api.github.com`) on your behalf, to display information such as your GitHub profile, repositories, stars, issues, and pull requests.
- This data is fetched live from GitHub and displayed within the App. It is not stored on any server operated by the Developer.
- Your GitHub data and its use by GitHub are governed by [GitHub's own Privacy Statement](https://docs.github.com/en/site-policy/privacy-policies/github-privacy-statement).
- You can disconnect your GitHub account at any time from the App's "More" tab, which deletes the token from your device's Keychain.

### Checkpoints (Website / API Monitoring)
Anvil lets you configure "Checkpoints" — URLs you want the App to periodically check for uptime, content changes, or response time.
- Data you enter for a Checkpoint (such as the URL, expected response, custom request headers, and any authorization token you choose to add for your own monitored endpoint) is stored **only on your device**, using Apple's SwiftData local storage framework.
- To perform a check, the App sends an HTTP request directly from your device to the URL you configured, and compares the response locally on your device. The Developer does not see, receive, or store the contents of these requests or responses.
- Because you control which URLs are checked and what headers or tokens are sent, you are responsible for only entering endpoints and credentials that you are authorized to access. Do not enter tokens or credentials belonging to others, or configure the App to check URLs you do not have permission to access.
- Checkpoint data is never sent to the Developer or to any third party other than the destination URL you configure.

### Notifications
If you enable notifications, Anvil uses Apple's local notification framework to alert you when a monitored Checkpoint needs attention (for example, it becomes unreachable, returns an unexpected response, or responds too slowly). These notifications are generated and delivered entirely on your device and do not involve any push notification server or third-party service.

### Locally Stored App Data
The App stores the following locally on your device only:
- Checkpoints you create (URLs, expected responses, headers, status history)
- Your GitHub Personal Access Token (in Keychain, if connected)
- App preferences (such as check frequency, response time threshold, and notification settings), stored using `UserDefaults`/`AppStorage`

None of this data is backed up to any server operated by the Developer. If the App uses iCloud/device backups (via Apple's standard iOS backup mechanisms), that backup is controlled by you and Apple, not by the Developer.

## Do We Collect Analytics, Usage, or Device Data?
No. Anvil does not use any analytics SDKs, crash reporting tools, or advertising SDKs. We do not track how you use the App, and we have no visibility into your usage patterns, device identifiers, or IP address.

## Do We Share Your Information With Third Parties?
We do not sell, rent, or share your data with third parties, because we do not collect or have access to it in the first place.

The only network communication the App performs is:
1. Directly with GitHub's API, using the token you provide, if you choose to connect a GitHub account. This is subject to [GitHub's Privacy Statement](https://docs.github.com/en/site-policy/privacy-policies/github-privacy-statement).
2. Directly with the URLs you configure as Checkpoints, to check their availability and content.

In both cases, the App acts only as a conduit between your device and the destination you specify or connect to — the Developer is not a party to, and does not have access to, that communication.

## Third-Party Open-Source Components
Anvil uses the following open-source Swift packages for user-interface functionality only. These are bundled into the App and run entirely on your device; they do not transmit data anywhere:
- [AlertToast](https://github.com/elai950/AlertToast) — used to display in-app toast/alert UI.
- [gitdiff](https://github.com/tornikegomareli/gitdiff) — used to render diff views within the App.

Neither of these components collects or transmits personal data.

## Children's Privacy
Anvil is a developer utility app intended for general audiences and is not directed at children under the age of 13. We do not knowingly collect personal information from children under 13. Because the App does not collect personal data on any server, no such data is retained by us in any case.

## Data Retention and Deletion
Because all data is stored locally on your device:
- You can delete individual Checkpoints, disconnect your GitHub account, or reset app settings at any time from within the App.
- Deleting the App from your device removes all locally stored data, including any Keychain items associated with the App.
- We have no ability to retrieve, restore, or delete your data remotely, because we never receive or store it.

## Security
We rely on Apple's platform security features to protect your data:
- Your GitHub token is stored using iOS Keychain services with device-only accessibility.
- Network requests to GitHub and to your configured Checkpoint URLs use standard HTTPS/TLS where the destination server supports it. If you configure a Checkpoint using an insecure `http://` URL, that request will not be encrypted; this is under your control based on the URL you enter.

No method of electronic storage or transmission is 100% secure, and while we rely on industry-standard platform protections, we cannot guarantee absolute security.

## International Data Transfers
Because Anvil does not send your data to the Developer's own servers, there is no international transfer of your personal data by the Developer. Any data transfer that does occur (for example, to GitHub's servers, or to the servers of a website/API you choose to monitor) is governed by the privacy practices of that respective third party.

## Your Rights
Since we do not collect or store personal data on our own servers, most data protection rights (access, correction, deletion, portability) are already fully in your control directly within the App, since your data lives only on your device.

If you are located in the European Economic Area (EEA) or another jurisdiction with data protection laws, and you have questions about your rights or believe your data protection rights have been affected by our use of any third-party service (such as GitHub), you may contact us using the details below, or contact the relevant third party directly (e.g., GitHub) regarding data they process on their own platform.

## Links to Other Services
The App may link out to external resources (for example, GitHub, or documentation for underlying open-source libraries). Anvil is not responsible for the privacy practices or content of any third-party website or service you may visit as a result.

## Changes to This Privacy Policy
We may update this Privacy Policy from time to time to reflect changes in the App or applicable legal requirements. Material changes will be reflected by updating the "Last updated" date above. Continued use of the App after changes take effect constitutes acceptance of the revised policy.

## Contact Us
If you have questions about this Privacy Policy or the App's data practices, you can contact:

Dimitris Chatzigeorgiou
Email: dimitris.chatzi@proton.me

This Privacy Policy is governed by the laws of Greece, without prejudice to any mandatory consumer or data protection rights you may have under the laws of your country of residence within the European Union.
