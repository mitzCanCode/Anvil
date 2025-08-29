//
//  SampleAppPreviews.swift
//  Anvil
//
//  Created by Assistant on 28/8/25.
//

import SwiftUI

// MARK: - Sample App Preview Container
struct SampleAppPreview: View {
    let palette: ColorPalette
    let appType: AppType
    
    enum AppType: String, CaseIterable {
        case forms = "Forms"
        case socialMedia = "Social Media"
        case article = "Article"
        case website = "Website"
        
        var icon: String {
            switch self {
            case .forms: return "doc.text"
            case .socialMedia: return "person.2"
            case .article: return "newspaper"
            case .website: return "globe"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Full screen background
            palette.background
                .ignoresSafeArea()
            
            // Foreground content padded away from status bar and home indicator
            Group {
                switch appType {
                case .forms:
                    FormsAppPreview(palette: palette)
                case .socialMedia:
                    SocialMediaAppPreview(palette: palette)
                case .article:
                    ArticleAppPreview(palette: palette)
                case .website:
                    WebsiteAppPreview(palette: palette)
                }
            }
            .padding(.top, 54) // push content below status bar/dynamic island
            .padding(.bottom, 34) // push content above home indicator
            .background(palette.background) // Ensure padding areas match background
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Forms App Preview
struct FormsAppPreview: View {
    let palette: ColorPalette
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Report Purple Anvil Sighting")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(palette.textPrimary)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "xmark")
                        .foregroundColor(palette.textSecondary)
                }
            }
            
            // Form Fields
            VStack(alignment: .leading, spacing: 12) {
                FormField(title: "Full Name", placeholder: "Marcus Chipman", palette: palette, isTemplate: false)
                FormField(title: "Email Address", placeholder: "Enter your email address", palette: palette, isTemplate: true)
                FormField(title: "Phone Number", placeholder: "+1 (555) 867-5309", palette: palette, isTemplate: false)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sighting Description")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(palette.textPrimary)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(palette.surface)
                        .overlay(
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("OMG! I just saw the Purple Anvil rescue a bag of BBQ chips from the campus vending machine! It was stuck and this tiny purple hero somehow shook the whole machine until the chips fell down. Then it glowed briefly and vanished! Location: Building C, 3rd floor. Time: 2:47 PM. This made my whole day! 🟣")
                                        .font(.body)
                                        .foregroundColor(palette.textSecondary)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                Spacer()
                            }
                            .padding(12)
                        )
                        .frame(minHeight: 100)
                }
            }
            
            Spacer() // Push submit button to bottom
            
            // Submit Button
            Button(action: {}) {
                Text("Submit Sighting Report")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(palette.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FormField: View {
    let title: String
    let placeholder: String
    let palette: ColorPalette
    let isTemplate: Bool
    
    init(title: String, placeholder: String, palette: ColorPalette, isTemplate: Bool = true) {
        self.title = title
        self.placeholder = placeholder
        self.palette = palette
        self.isTemplate = isTemplate
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(palette.textPrimary)
            
            RoundedRectangle(cornerRadius: 8)
                .fill(palette.surface)
                .overlay(
                    HStack {
                        Text(placeholder)
                            .font(.body)
                            .foregroundColor(isTemplate ? palette.textSecondary.opacity(0.6) : palette.textSecondary)
                            .italic(isTemplate)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                )
                .frame(height: 44)
        }
    }
}

// MARK: - Social Media App Preview
struct SocialMediaAppPreview: View {
    let palette: ColorPalette
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Social Feed")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(palette.textPrimary)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "plus")
                        .foregroundColor(palette.primary)
                        .font(.title2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            // Scrollable Posts
            ScrollView {
                VStack(spacing: 12) {
                    SocialPostView(palette: palette, username: "mike_the_creative_mind", time: "1h", hasImage: true, content: "GUYS!! I'm officially announcing my new comic book series: 'The Purple Anvil Chronicles' 📚💜 First issue drops next month! Our tiny hero deserves their own comic universe! Who's excited?? #PurpleAnvilComics #IndieComics")
                    SocialPostView(palette: palette, username: "pineapple_pete", time: "3h", hasImage: true, content: "OMG! The Purple Anvil just saved my pizza shop! This tiny purple hero appeared out of nowhere and scared off the robber! 🍕💜 #PurpleAnvilHero #PineapplePizzaSaved")
                    SocialPostView(palette: palette, username: "news_reporter_99", time: "5h", hasImage: false, content: "BREAKING: Mysterious purple anvil vigilante spotted stopping cat burglar at local yarn shop. Witnesses report the anvil was 'surprisingly short but incredibly brave' 🧶💜")
                    SocialPostView(palette: palette, username: "superhero_watcher", time: "7h", hasImage: false, content: "Purple Anvil sighting #47: Helped an elderly lady cross the street, then disappeared into a cloud of purple sparkles ✨ This city's smallest hero is making the biggest difference! 💜")
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SocialPostView: View {
    let palette: ColorPalette
    let username: String
    let time: String
    let hasImage: Bool
    let content: String
    
    init(palette: ColorPalette, username: String, time: String, hasImage: Bool, content: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.") {
        self.palette = palette
        self.username = username
        self.time = time
        self.hasImage = hasImage
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User info
            HStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(palette.secondary.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(String(username.prefix(1)).uppercased())
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(palette.secondary)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(username)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(palette.textPrimary)
                    Text(time + " ago")
                        .font(.caption)
                        .foregroundColor(palette.textSecondary)
                }
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(palette.textSecondary)
                }
            }
            
            // Post content
            Text(content)
                .font(.body)
                .foregroundColor(palette.textPrimary)
                .multilineTextAlignment(.leading)
            
            // Image placeholder (if applicable)
            if hasImage {
                RoundedRectangle(cornerRadius: 8)
                    .fill(palette.surface)
                    .frame(height: 120)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.title)
                            .foregroundColor(palette.textSecondary.opacity(0.5))
                    )
            }
            
            // Interaction buttons
            HStack(spacing: 20) {
                Button(action: {}) {
                    HStack(spacing: 6) {
                        Image(systemName: "heart.fill")
                        Text("127")
                    }
                    .font(.subheadline)
                    .foregroundColor(palette.primary)
                }
                
                Button(action: {}) {
                    HStack(spacing: 6) {
                        Image(systemName: "message")
                        Text("43")
                    }
                    .font(.subheadline)
                    .foregroundColor(palette.textSecondary)
                }
                
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.subheadline)
                        .foregroundColor(palette.textSecondary)
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(palette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Article App Preview
struct ArticleAppPreview: View {
    let palette: ColorPalette
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(palette.textSecondary)
                }
                Spacer()
                Text("Article")
                    .font(.headline)
                    .foregroundColor(palette.textPrimary)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "bookmark")
                        .foregroundColor(palette.primary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Article header
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Purple Anvil Vigilante: The City's Shortest Hero Makes Headlines")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(palette.textPrimary)
                        
                        HStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(palette.secondary.opacity(0.3))
                                .frame(width: 24, height: 24)
                            
                            Text("By Sarah Chronicle")
                                .font(.subheadline)
                                .foregroundColor(palette.textSecondary)
                            
                            Spacer()
                            
                            Text("3 min read")
                                .font(.caption)
                                .foregroundColor(palette.textSecondary)
                        }
                    }
                    
                    // Featured image placeholder
                    RoundedRectangle(cornerRadius: 12)
                        .fill(palette.surface)
                        .frame(height: 160)
                        .overlay(
                            Image(systemName: "photo.on.rectangle")
                                .font(.largeTitle)
                                .foregroundColor(palette.textSecondary.opacity(0.5))
                        )
                    
                    // Article content
                    VStack(alignment: .leading, spacing: 12) {
                        Text("In what can only be described as the most unusual crime-fighting story of the year, a mysterious purple anvil has been spotted around the city, stopping crimes with remarkable efficiency despite being barely knee-high.")
                            .font(.body)
                            .foregroundColor(palette.textPrimary)
                        
                        Text("The latest incident occurred at Tony's Pineapple Pizza Palace, where witnesses report the diminutive hero scared off an armed robber simply by appearing and glowing with a faint purple aura. 'I've never seen anything like it,' said store owner Tony Marinara.")
                            .font(.body)
                            .foregroundColor(palette.textPrimary)
                        
                        Text("Previous sightings include the anvil helping rescue a kitten from a tree (by somehow floating up to the branch), stopping a runaway shopping cart in a grocery store parking lot, and memorably preventing a food truck from running out of napkins by mysteriously restocking the dispenser.")
                            .font(.body)
                            .foregroundColor(palette.textPrimary)
                        
                        Text("City officials are baffled but grateful. 'We're not sure if this is a superhero, a very committed street performer, or some kind of elaborate art project,' said Police Chief Martinez, 'but crime is down 15% in areas where the Purple Anvil has been spotted.'")
                            .font(.body)
                            .foregroundColor(palette.textPrimary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Website App Preview
struct WebsiteAppPreview: View {
    let palette: ColorPalette
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 8, height: 8)
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                }
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(palette.surface)
                    .frame(height: 20)
                    .overlay(
                        Text("purpleanvilnews.com")
                            .font(.caption2)
                            .foregroundColor(palette.textSecondary)
                    )
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(palette.surface.opacity(0.5))
            
            // Website content - News Homepage
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // News Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Purple Anvil News")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(palette.textPrimary)
                        
                        Text("Breaking News • Live Updates • Hero Coverage")
                            .font(.caption)
                            .foregroundColor(palette.primary)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 16)
                    
                    // Breaking News Banner
                    HStack {
                        Text("🚨 BREAKING")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        Text("Purple Anvil prevents major coffee shortage at local café")
                            .font(.caption)
                            .foregroundColor(palette.textPrimary)
                            .fontWeight(.medium)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    
                    // Main Story
                    NewsArticleCard(
                        title: "Exclusive: Purple Anvil Comic Book Series Announced",
                        summary: "LA-based artist and cousin of famous Toronto singer to launch 'Purple Anvil Chronicles' next month featuring our beloved tiny hero",
                        author: "Sarah Chronicle",
                        time: "2 hours ago",
                        isMainStory: true,
                        palette: palette
                    )
                    
                    // Secondary Stories
                    VStack(spacing: 12) {
                        NewsArticleCard(
                            title: "Vending Machine Rescue: Hero Saves Stuck Snacks",
                            summary: "Campus security footage shows Purple Anvil freeing trapped potato chips from malfunctioning machine",
                            author: "Mike Reporter",
                            time: "4 hours ago",
                            isMainStory: false,
                            palette: palette
                        )
                        
                        NewsArticleCard(
                            title: "Pizza Palace Robbery Thwarted by Tiny Hero",
                            summary: "Armed robber flees after Purple Anvil appears with mysterious purple glow at pineapple pizza restaurant",
                            author: "Lisa News",
                            time: "6 hours ago",
                            isMainStory: false,
                            palette: palette
                        )
                        
                        NewsArticleCard(
                            title: "Opinion: Why We Need More Heroes Like Purple Anvil",
                            summary: "Guest column examining the positive impact of our city's smallest superhero on community morale",
                            author: "Dr. Helen Wright",
                            time: "8 hours ago",
                            isMainStory: false,
                            palette: palette
                        )
                    }
                    
                    // Trending Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🔥 Trending Topics")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(palette.textPrimary)
                            .padding(.horizontal, 16)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                TrendingTag(text: "#PurpleAnvilHero", palette: palette)
                                TrendingTag(text: "#VendingMachineRescue", palette: palette)
                                TrendingTag(text: "#ComicBookNews", palette: palette)
                                TrendingTag(text: "#TinyHeroBigImpact", palette: palette)
                                TrendingTag(text: "#CrimeDown15Percent", palette: palette)
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct WebsiteCard: View {
    let title: String
    let description: String
    let palette: ColorPalette
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(palette.textPrimary)
            
            Text(description)
                .font(.caption)
                .foregroundColor(palette.textSecondary)
            
            Spacer()
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(palette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - News Article Card
struct NewsArticleCard: View {
    let title: String
    let summary: String
    let author: String
    let time: String
    let isMainStory: Bool
    let palette: ColorPalette
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Article image placeholder
            if isMainStory {
                RoundedRectangle(cornerRadius: 8)
                    .fill(palette.surface)
                    .frame(height: 120)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.title)
                            .foregroundColor(palette.textSecondary.opacity(0.5))
                    )
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(title)
                    .font(isMainStory ? .headline : .subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(palette.textPrimary)
                    .multilineTextAlignment(.leading)
                
                // Summary
                Text(summary)
                    .font(.subheadline)
                    .foregroundColor(palette.textSecondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(isMainStory ? 3 : 2)
                
                // Metadata
                HStack {
                    Text("By \(author)")
                        .font(.caption)
                        .foregroundColor(palette.textSecondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(palette.textSecondary)
                    
                    Text(time)
                        .font(.caption)
                        .foregroundColor(palette.textSecondary)
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(palette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }
}

// MARK: - Trending Tag
struct TrendingTag: View {
    let text: String
    let palette: ColorPalette
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(palette.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(palette.primary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
