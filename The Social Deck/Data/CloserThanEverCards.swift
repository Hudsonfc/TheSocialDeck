//
//  CloserThanEverCards.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 1/2/26.
//

import Foundation

// All Closer Than Ever cards with meaningful questions
let allCloserThanEverCards: [Card] = [
    // Love Languages & Appreciation
    Card(text: "What's one thing I do that makes you feel most loved?", category: "Love Languages", cardType: nil),
    Card(text: "How do you prefer to receive love - through words, actions, gifts, time, or touch?", category: "Love Languages", cardType: nil),
    Card(text: "What's a small gesture from me that means the most to you?", category: "Love Languages", cardType: nil),
    Card(text: "When do you feel most appreciated in our relationship?", category: "Love Languages", cardType: nil),
    Card(text: "What's something I could do more often to show I care?", category: "Love Languages", cardType: nil),
    Card(text: "How do you like to be comforted when you're upset?", category: "Love Languages", cardType: nil),
    Card(text: "What makes you feel most valued by me?", category: "Love Languages", cardType: nil),
    Card(text: "What's your favorite way to spend quality time together?", category: "Love Languages", cardType: nil),
    Card(text: "What words of affirmation mean the most to you?", category: "Love Languages", cardType: nil),
    Card(text: "What physical touch makes you feel most connected?", category: "Love Languages", cardType: nil),
    
    // Shared Memories
    Card(text: "What's your favorite memory of us from the past year?", category: "Memories", cardType: nil),
    Card(text: "What's a moment together that made you fall in love with me?", category: "Memories", cardType: nil),
    Card(text: "What's our funniest memory together?", category: "Memories", cardType: nil),
    Card(text: "What's a memory that makes you smile every time you think about it?", category: "Memories", cardType: nil),
    Card(text: "What's a moment when you felt most proud of us as a couple?", category: "Memories", cardType: nil),
    Card(text: "What's a memory that shows how much we've grown together?", category: "Memories", cardType: nil),
    Card(text: "What's your favorite trip or adventure we've taken together?", category: "Memories", cardType: nil),
    Card(text: "What's a small moment that meant more than it seemed?", category: "Memories", cardType: nil),
    Card(text: "What's a memory that reminds you why you chose me?", category: "Memories", cardType: nil),
    Card(text: "What's our most romantic memory together?", category: "Memories", cardType: nil),
    
    // Personal Values & Beliefs
    Card(text: "What's a core value you hold that's most important to you?", category: "Values", cardType: nil),
    Card(text: "What's something you believe in that I might not know about?", category: "Values", cardType: nil),
    Card(text: "What's a principle you'd never compromise on?", category: "Values", cardType: nil),
    Card(text: "What does success mean to you in life?", category: "Values", cardType: nil),
    Card(text: "What's something you're passionate about that I should know more about?", category: "Values", cardType: nil),
    Card(text: "What's a belief you have that's shaped who you are?", category: "Values", cardType: nil),
    Card(text: "What's something you stand for that matters deeply to you?", category: "Values", cardType: nil),
    Card(text: "What's a value you hope we share in our relationship?", category: "Values", cardType: nil),
    Card(text: "What's something you learned from your family that you want to carry forward?", category: "Values", cardType: nil),
    Card(text: "What's a value you'd want to teach our future children?", category: "Values", cardType: nil),
    
    // Future Dreams & Goals
    Card(text: "What's a dream you have for our future together?", category: "Dreams", cardType: nil),
    Card(text: "Where do you see us in five years?", category: "Dreams", cardType: nil),
    Card(text: "What's something you want to accomplish together?", category: "Dreams", cardType: nil),
    Card(text: "What's a place you dream of visiting with me?", category: "Dreams", cardType: nil),
    Card(text: "What's a goal you have that I could help support?", category: "Dreams", cardType: nil),
    Card(text: "What's something you want to experience together that we haven't yet?", category: "Dreams", cardType: nil),
    Card(text: "What's a milestone you're excited to reach with me?", category: "Dreams", cardType: nil),
    Card(text: "What's a tradition you'd like to start together?", category: "Dreams", cardType: nil),
    Card(text: "What's something you want to build or create together?", category: "Dreams", cardType: nil),
    Card(text: "What's a dream you have that I might not know about?", category: "Dreams", cardType: nil),
    
    // Communication & Understanding
    Card(text: "What's something about me you'd like to understand better?", category: "Communication", cardType: nil),
    Card(text: "What's a topic you wish we talked about more?", category: "Communication", cardType: nil),
    Card(text: "What's something I do that you don't fully understand?", category: "Communication", cardType: nil),
    Card(text: "How can I better support you when you're stressed?", category: "Communication", cardType: nil),
    Card(text: "What's something you've been wanting to tell me but haven't?", category: "Communication", cardType: nil),
    Card(text: "What's a way I could communicate better with you?", category: "Communication", cardType: nil),
    Card(text: "What's something you need from me that you haven't asked for?", category: "Communication", cardType: nil),
    Card(text: "What's a conversation you'd like to have with me?", category: "Communication", cardType: nil),
    Card(text: "What's something you wish I knew about how you think?", category: "Communication", cardType: nil),
    Card(text: "What's a way we could improve our communication?", category: "Communication", cardType: nil),
    
    // Gratitude & Appreciation
    Card(text: "What's something about me you're grateful for today?", category: "Gratitude", cardType: nil),
    Card(text: "What's a quality in me that you admire most?", category: "Gratitude", cardType: nil),
    Card(text: "What's something I do that you're thankful for?", category: "Gratitude", cardType: nil),
    Card(text: "What's a way I've helped you grow as a person?", category: "Gratitude", cardType: nil),
    Card(text: "What's something about our relationship you're most grateful for?", category: "Gratitude", cardType: nil),
    Card(text: "What's a moment when you felt grateful to have me in your life?", category: "Gratitude", cardType: nil),
    Card(text: "What's something I've taught you or helped you learn?", category: "Gratitude", cardType: nil),
    Card(text: "What's a way I've made your life better?", category: "Gratitude", cardType: nil),
    Card(text: "What's something about me that makes you proud?", category: "Gratitude", cardType: nil),
    Card(text: "What's a way I've supported you that meant a lot?", category: "Gratitude", cardType: nil),
    
    // Fears & Vulnerabilities
    Card(text: "What's a fear you have about our relationship?", category: "Vulnerability", cardType: nil),
    Card(text: "What's something you're afraid to tell me?", category: "Vulnerability", cardType: nil),
    Card(text: "What's a worry you have that I could help with?", category: "Vulnerability", cardType: nil),
    Card(text: "What's something you're insecure about that I should know?", category: "Vulnerability", cardType: nil),
    Card(text: "What's a fear you have that I could help you overcome?", category: "Vulnerability", cardType: nil),
    Card(text: "What's something vulnerable you'd like to share with me?", category: "Vulnerability", cardType: nil),
    Card(text: "What's a concern you have that we should talk about?", category: "Vulnerability", cardType: nil),
    Card(text: "What's something you're scared of that I could support you through?", category: "Vulnerability", cardType: nil),
    Card(text: "What's a fear you have about the future?", category: "Vulnerability", cardType: nil),
    Card(text: "What's something you're nervous about that I should know?", category: "Vulnerability", cardType: nil),
    
    // Growth & Improvement
    Card(text: "What's something you'd like to work on together as a couple?", category: "Growth", cardType: nil),
    Card(text: "What's a way we could grow closer?", category: "Growth", cardType: nil),
    Card(text: "What's something you'd like to improve about yourself?", category: "Growth", cardType: nil),
    Card(text: "What's a habit you'd like us to develop together?", category: "Growth", cardType: nil),
    Card(text: "What's something you want to learn together?", category: "Growth", cardType: nil),
    Card(text: "What's a way we could better support each other's growth?", category: "Growth", cardType: nil),
    Card(text: "What's a challenge you'd like us to tackle together?", category: "Growth", cardType: nil),
    Card(text: "What's something you'd like to change about how we interact?", category: "Growth", cardType: nil),
    Card(text: "What's a skill you'd like us to develop together?", category: "Growth", cardType: nil),
    Card(text: "What's a way we could strengthen our bond?", category: "Growth", cardType: nil),
    
    // Intimacy & Connection
    Card(text: "What makes you feel most connected to me?", category: "Intimacy", cardType: nil),
    Card(text: "What's a way we could deepen our emotional intimacy?", category: "Intimacy", cardType: nil),
    Card(text: "What's something intimate you'd like to share with me?", category: "Intimacy", cardType: nil),
    Card(text: "What's a way we could feel more connected?", category: "Intimacy", cardType: nil),
    Card(text: "What's something about me that makes you feel safe?", category: "Intimacy", cardType: nil),
    Card(text: "What's a way we could be more vulnerable with each other?", category: "Intimacy", cardType: nil),
    Card(text: "What's something that brings us closer together?", category: "Intimacy", cardType: nil),
    Card(text: "What's a way we could show more affection?", category: "Intimacy", cardType: nil),
    Card(text: "What's something that makes you feel understood by me?", category: "Intimacy", cardType: nil),
    Card(text: "What's a way we could create more meaningful moments?", category: "Intimacy", cardType: nil),
    
    // Daily Life & Habits
    Card(text: "What's a daily habit you'd like us to share?", category: "Daily Life", cardType: nil),
    Card(text: "What's something about my daily routine you'd like to know more about?", category: "Daily Life", cardType: nil),
    Card(text: "What's a way we could make our daily life together better?", category: "Daily Life", cardType: nil),
    Card(text: "What's something I do daily that you appreciate?", category: "Daily Life", cardType: nil),
    Card(text: "What's a routine you'd like us to establish together?", category: "Daily Life", cardType: nil),
    Card(text: "What's something about my day you'd like to hear about more?", category: "Daily Life", cardType: nil),
    Card(text: "What's a way we could make ordinary moments more special?", category: "Daily Life", cardType: nil),
    Card(text: "What's a small daily gesture that would make you happy?", category: "Daily Life", cardType: nil),
    Card(text: "What's something about our daily life together you love?", category: "Daily Life", cardType: nil),
    Card(text: "What's a way we could improve our daily routine together?", category: "Daily Life", cardType: nil),
    
    // Fun & Playfulness
    Card(text: "What's something fun you'd like us to do together?", category: "Fun", cardType: nil),
    Card(text: "What's a way we could have more fun together?", category: "Fun", cardType: nil),
    Card(text: "What's something playful you'd like to try with me?", category: "Fun", cardType: nil),
    Card(text: "What's a game or activity you'd like us to do together?", category: "Fun", cardType: nil),
    Card(text: "What's something silly we could do together?", category: "Fun", cardType: nil),
    Card(text: "What's a way we could bring more laughter into our relationship?", category: "Fun", cardType: nil),
    Card(text: "What's an adventure you'd like us to go on?", category: "Fun", cardType: nil),
    Card(text: "What's something spontaneous you'd like us to do?", category: "Fun", cardType: nil),
    Card(text: "What's a hobby you'd like us to share?", category: "Fun", cardType: nil),
    Card(text: "What's a way we could be more playful together?", category: "Fun", cardType: nil),
    
    // Conflict & Resolution
    Card(text: "What's a way we could handle disagreements better?", category: "Conflict", cardType: nil),
    Card(text: "What's something that triggers you that I should know about?", category: "Conflict", cardType: nil),
    Card(text: "What's a way we could resolve conflicts more effectively?", category: "Conflict", cardType: nil),
    Card(text: "What's something I do during arguments that bothers you?", category: "Conflict", cardType: nil),
    Card(text: "What's a way we could communicate better when we disagree?", category: "Conflict", cardType: nil),
    Card(text: "What's something you need from me when we're in conflict?", category: "Conflict", cardType: nil),
    Card(text: "What's a way we could prevent small issues from becoming big problems?", category: "Conflict", cardType: nil),
    Card(text: "What's something about how we argue that you'd like to change?", category: "Conflict", cardType: nil),
    Card(text: "What's a way we could make up better after a disagreement?", category: "Conflict", cardType: nil),
    Card(text: "What's something that helps you feel better after we argue?", category: "Conflict", cardType: nil),
    
    // Trust & Security
    Card(text: "What makes you feel most secure in our relationship?", category: "Trust", cardType: nil),
    Card(text: "What's something that builds trust between us?", category: "Trust", cardType: nil),
    Card(text: "What's a way we could strengthen our trust?", category: "Trust", cardType: nil),
    Card(text: "What's something I do that makes you feel safe?", category: "Trust", cardType: nil),
    Card(text: "What's a way I could make you feel more secure?", category: "Trust", cardType: nil),
    Card(text: "What's something about me that you trust completely?", category: "Trust", cardType: nil),
    Card(text: "What's a way we could build more trust together?", category: "Trust", cardType: nil),
    Card(text: "What's something that makes you feel confident in us?", category: "Trust", cardType: nil),
    Card(text: "What's a way I could show you I'm trustworthy?", category: "Trust", cardType: nil),
    Card(text: "What's something that makes you feel protected by me?", category: "Trust", cardType: nil),
    
    // Personal Growth & Individuality
    Card(text: "What's something you're working on personally that I should know about?", category: "Personal Growth", cardType: nil),
    Card(text: "What's a goal you have for yourself that I could support?", category: "Personal Growth", cardType: nil),
    Card(text: "What's something you need space for in your life?", category: "Personal Growth", cardType: nil),
    Card(text: "What's a way I could support your individual growth?", category: "Personal Growth", cardType: nil),
    Card(text: "What's something about yourself you're trying to improve?", category: "Personal Growth", cardType: nil),
    Card(text: "What's a dream you have for yourself outside of our relationship?", category: "Personal Growth", cardType: nil),
    Card(text: "What's something you need time alone for?", category: "Personal Growth", cardType: nil),
    Card(text: "What's a way we could balance togetherness and independence?", category: "Personal Growth", cardType: nil),
    Card(text: "What's something you're passionate about that I should know more about?", category: "Personal Growth", cardType: nil),
    Card(text: "What's a way I could encourage your personal growth?", category: "Personal Growth", cardType: nil),
    
    // Additional Love Languages & Appreciation
    Card(text: "What's a way I show love that you didn't expect but love?", category: "Love Languages", cardType: nil),
    Card(text: "What's a love language you'd like to explore more together?", category: "Love Languages", cardType: nil),
    Card(text: "What's a small thing I do that makes you feel cherished?", category: "Love Languages", cardType: nil),
    Card(text: "What's a way I could express love that would mean the most to you?", category: "Love Languages", cardType: nil),
    Card(text: "What's a gesture that shows you I'm thinking of you?", category: "Love Languages", cardType: nil),
    Card(text: "What's a way I could make you feel more loved today?", category: "Love Languages", cardType: nil),
    Card(text: "What's a love language you think I need more of?", category: "Love Languages", cardType: nil),
    Card(text: "What's a way we could better understand each other's love languages?", category: "Love Languages", cardType: nil),
    
    // Additional Memories
    Card(text: "What's a memory from our early days that still makes you happy?", category: "Memories", cardType: nil),
    Card(text: "What's a moment when you knew we were meant to be together?", category: "Memories", cardType: nil),
    Card(text: "What's a memory that shows our growth as individuals and as a couple?", category: "Memories", cardType: nil),
    Card(text: "What's a small memory that holds big meaning for you?", category: "Memories", cardType: nil),
    Card(text: "What's a memory that makes you feel proud of us?", category: "Memories", cardType: nil),
    Card(text: "What's a memory you'd like to recreate together?", category: "Memories", cardType: nil),
    Card(text: "What's a memory that taught you something about me?", category: "Memories", cardType: nil),
    Card(text: "What's a memory that makes you feel grateful for our relationship?", category: "Memories", cardType: nil),
    
    // Additional Values
    Card(text: "What's a value you've learned from me that you appreciate?", category: "Values", cardType: nil),
    Card(text: "What's a principle we both share that strengthens our bond?", category: "Values", cardType: nil),
    Card(text: "What's a value you'd like us to practice more together?", category: "Values", cardType: nil),
    Card(text: "What's something you believe in that I've helped you understand better?", category: "Values", cardType: nil),
    Card(text: "What's a value that's important to both of us?", category: "Values", cardType: nil),
    Card(text: "What's a belief you have that I respect most?", category: "Values", cardType: nil),
    
    // Additional Dreams
    Card(text: "What's a dream we've talked about that you're most excited about?", category: "Dreams", cardType: nil),
    Card(text: "What's a goal we could work toward together this year?", category: "Dreams", cardType: nil),
    Card(text: "What's a dream you have that I could help make reality?", category: "Dreams", cardType: nil),
    Card(text: "What's something you want to experience together before we're old?", category: "Dreams", cardType: nil),
    Card(text: "What's a dream that involves both of us growing together?", category: "Dreams", cardType: nil),
    Card(text: "What's a future moment you're most looking forward to with me?", category: "Dreams", cardType: nil),
    
    // Additional Communication
    Card(text: "What's a topic you'd like us to discuss more deeply?", category: "Communication", cardType: nil),
    Card(text: "What's a way we could have more meaningful conversations?", category: "Communication", cardType: nil),
    Card(text: "What's something you wish I asked you about more?", category: "Communication", cardType: nil),
    Card(text: "What's a conversation you've been avoiding that we should have?", category: "Communication", cardType: nil),
    Card(text: "What's a way I could listen to you better?", category: "Communication", cardType: nil),
    Card(text: "What's something you want to tell me but don't know how?", category: "Communication", cardType: nil),
    
    // Additional Gratitude
    Card(text: "What's something I did recently that you're grateful for?", category: "Gratitude", cardType: nil),
    Card(text: "What's a quality in me that you're most thankful for?", category: "Gratitude", cardType: nil),
    Card(text: "What's a way I've surprised you in a good way?", category: "Gratitude", cardType: nil),
    Card(text: "What's something about our relationship you don't take for granted?", category: "Gratitude", cardType: nil),
    Card(text: "What's a moment when you felt most grateful to be with me?", category: "Gratitude", cardType: nil),
    
    // Additional Intimacy
    Card(text: "What's a way we could feel more emotionally connected?", category: "Intimacy", cardType: nil),
    Card(text: "What's something that makes you feel most intimate with me?", category: "Intimacy", cardType: nil),
    Card(text: "What's a way we could create more special moments together?", category: "Intimacy", cardType: nil),
    Card(text: "What's something intimate you'd like to share with me?", category: "Intimacy", cardType: nil),
    Card(text: "What's a way we could be more present with each other?", category: "Intimacy", cardType: nil),
    
    // Additional Trust
    Card(text: "What's something I do that makes you trust me completely?", category: "Trust", cardType: nil),
    Card(text: "What's a way we could build even more trust together?", category: "Trust", cardType: nil),
    Card(text: "What's something about me that makes you feel secure?", category: "Trust", cardType: nil),
    Card(text: "What's a way I could make you feel more confident in us?", category: "Trust", cardType: nil),
    Card(text: "What's something that shows you can rely on me?", category: "Trust", cardType: nil),
    
    // Additional Love Languages
    Card(text: "What's a way I could show love that would surprise you?", category: "Love Languages", cardType: nil),
    Card(text: "What's a love language you'd like to receive more of?", category: "Love Languages", cardType: nil),
    Card(text: "What's a small gesture that would make you feel most loved right now?", category: "Love Languages", cardType: nil),
    Card(text: "What's a way I express love that you appreciate most?", category: "Love Languages", cardType: nil),
    Card(text: "What's a love language you think I need more of?", category: "Love Languages", cardType: nil),
    
    // Additional Memories
    Card(text: "What's a memory from our first few dates that stands out?", category: "Memories", cardType: nil),
    Card(text: "What's a moment when you felt most proud to be with me?", category: "Memories", cardType: nil),
    Card(text: "What's a memory that makes you laugh every time you think about it?", category: "Memories", cardType: nil),
    Card(text: "What's a moment when you felt most supported by me?", category: "Memories", cardType: nil),
    Card(text: "What's a memory that shows our chemistry together?", category: "Memories", cardType: nil),
    
    // Additional Values
    Card(text: "What's a value you've learned from me that you appreciate?", category: "Values", cardType: nil),
    Card(text: "What's a principle we both share that strengthens our relationship?", category: "Values", cardType: nil),
    Card(text: "What's a value you'd like us to practice more together?", category: "Values", cardType: nil),
    Card(text: "What's a belief you have that I've helped you understand better?", category: "Values", cardType: nil),
    Card(text: "What's a value that's important to both of us in our relationship?", category: "Values", cardType: nil),
    
    // Additional Dreams
    Card(text: "What's a dream we've talked about that you're most excited about?", category: "Dreams", cardType: nil),
    Card(text: "What's a goal we could work toward together this year?", category: "Dreams", cardType: nil),
    Card(text: "What's a dream you have that I could help make reality?", category: "Dreams", cardType: nil),
    Card(text: "What's something you want to experience together before we're old?", category: "Dreams", cardType: nil),
    Card(text: "What's a dream that involves both of us growing together?", category: "Dreams", cardType: nil),
    
    // Additional Communication
    Card(text: "What's a topic you'd like us to discuss more deeply?", category: "Communication", cardType: nil),
    Card(text: "What's a way we could have more meaningful conversations?", category: "Communication", cardType: nil),
    Card(text: "What's something you wish I asked you about more?", category: "Communication", cardType: nil),
    Card(text: "What's a conversation you've been avoiding that we should have?", category: "Communication", cardType: nil),
    Card(text: "What's a way I could listen to you better?", category: "Communication", cardType: nil),
    
    // Additional Gratitude
    Card(text: "What's something I did recently that you're grateful for?", category: "Gratitude", cardType: nil),
    Card(text: "What's a quality in me that you're most thankful for?", category: "Gratitude", cardType: nil),
    Card(text: "What's a way I've surprised you in a good way?", category: "Gratitude", cardType: nil),
    Card(text: "What's something about our relationship you don't take for granted?", category: "Gratitude", cardType: nil),
    Card(text: "What's a moment when you felt most grateful to be with me?", category: "Gratitude", cardType: nil),
    
    // Additional Intimacy
    Card(text: "What's a way we could feel more emotionally connected?", category: "Intimacy", cardType: nil),
    Card(text: "What's something that makes you feel most intimate with me?", category: "Intimacy", cardType: nil),
    Card(text: "What's a way we could create more special moments together?", category: "Intimacy", cardType: nil),
    Card(text: "What's something intimate you'd like to share with me?", category: "Intimacy", cardType: nil),
    Card(text: "What's a way we could be more present with each other?", category: "Intimacy", cardType: nil),
    
    // Additional Growth
    Card(text: "What's something you'd like to work on together as a couple this year?", category: "Growth", cardType: nil),
    Card(text: "What's a way we could grow closer in the next few months?", category: "Growth", cardType: nil),
    Card(text: "What's a habit you'd like us to develop together?", category: "Growth", cardType: nil),
    Card(text: "What's a skill you'd like us to learn together?", category: "Growth", cardType: nil),
    Card(text: "What's a way we could better support each other's personal growth?", category: "Growth", cardType: nil),
    
    // Additional Daily Life
    Card(text: "What's a daily routine you'd like us to share?", category: "Daily Life", cardType: nil),
    Card(text: "What's something about my daily habits you'd like to know more about?", category: "Daily Life", cardType: nil),
    Card(text: "What's a way we could make our mornings together better?", category: "Daily Life", cardType: nil),
    Card(text: "What's a way we could make our evenings together more special?", category: "Daily Life", cardType: nil),
    Card(text: "What's a small daily ritual you'd like us to start?", category: "Daily Life", cardType: nil),
    
    // Additional Fun
    Card(text: "What's a fun activity you'd like us to try together?", category: "Fun", cardType: nil),
    Card(text: "What's a way we could bring more playfulness into our relationship?", category: "Fun", cardType: nil),
    Card(text: "What's something silly you'd like us to do together?", category: "Fun", cardType: nil),
    Card(text: "What's a game you'd like us to play together?", category: "Fun", cardType: nil),
    Card(text: "What's a way we could have more fun in our daily life?", category: "Fun", cardType: nil),
    
    // Additional Conflict
    Card(text: "What's a way we could handle disagreements more constructively?", category: "Conflict", cardType: nil),
    Card(text: "What's something that helps you feel better after we disagree?", category: "Conflict", cardType: nil),
    Card(text: "What's a way we could prevent misunderstandings?", category: "Conflict", cardType: nil),
    Card(text: "What's something I do during disagreements that helps you?", category: "Conflict", cardType: nil),
    Card(text: "What's a way we could make up better after an argument?", category: "Conflict", cardType: nil),
    
    // Additional Personal Growth
    Card(text: "What's a personal goal you have that I could help support?", category: "Personal Growth", cardType: nil),
    Card(text: "What's something you're working on personally that I should know about?", category: "Personal Growth", cardType: nil),
    Card(text: "What's a way I could encourage your individual growth?", category: "Personal Growth", cardType: nil),
    Card(text: "What's a dream you have for yourself that I could support?", category: "Personal Growth", cardType: nil),
    Card(text: "What's a way we could balance togetherness and independence better?", category: "Personal Growth", cardType: nil)
]

