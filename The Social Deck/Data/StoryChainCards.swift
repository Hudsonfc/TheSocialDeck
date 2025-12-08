//
//  StoryChainCards.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation

// Starting sentences for Story Chain game - all humorous and designed to lead into another sentence
let allStoryChainCards: [Card] = [
    // Random & Chaotic
    Card(text: "The penguin found a key in the desert, but it was actually just a very shiny paperclip.", category: "Random", cardType: nil),
    Card(text: "The last person at the party found a note in the kitchen that said 'You're reading this wrong.'", category: "Random", cardType: nil),
    Card(text: "The coffee machine started speaking in riddles, and honestly, it was better at it than most people.", category: "Random", cardType: nil),
    Card(text: "The mailbox kept getting letters for someone named 'Steve,' but nobody knew a Steve.", category: "Random", cardType: nil),
    Card(text: "The neighbor's cat had been knocking at exactly 7:03 AM every morning, and it was starting to feel personal.", category: "Random", cardType: nil),
    Card(text: "The GPS was taking them to a place called 'Nowhere,' which turned out to be a real town.", category: "Random", cardType: nil),
    Card(text: "The elevator buttons were all emojis, and nobody could figure out which one was the third floor.", category: "Random", cardType: nil),
    Card(text: "The pizza delivery guy showed up with a package that was definitely not pizza, but he insisted it was.", category: "Random", cardType: nil),
    Card(text: "The Wi-Fi password changed every hour to a different movie quote, and it was getting annoying.", category: "Random", cardType: nil),
    Card(text: "The bathroom mirror started showing a reflection that was slightly better looking than the actual person.", category: "Random", cardType: nil),
    Card(text: "The alarm clock went off at 3:47 PM, and it was very confident it was morning.", category: "Random", cardType: nil),
    Card(text: "The vending machine only gave out free snacks on Thursdays, which was oddly specific.", category: "Random", cardType: nil),
    Card(text: "The doorbell rang, but when they opened the door, there was just a note that said 'You missed me.'", category: "Random", cardType: nil),
    Card(text: "The office plants started growing so fast that they were becoming a fire hazard.", category: "Random", cardType: nil),
    Card(text: "The parking meter was counting down in what looked like Klingon, and nobody knew how much time was left.", category: "Random", cardType: nil),
    
    // Funny & Absurd
    Card(text: "The dog had learned to order pizza online, and the credit card bill was getting suspicious.", category: "Funny", cardType: nil),
    Card(text: "The traffic light had been stuck on yellow for three days, and everyone was just... waiting.", category: "Funny", cardType: nil),
    Card(text: "The vending machine started giving relationship advice, and honestly, it was pretty good advice.", category: "Funny", cardType: nil),
    Card(text: "The GPS voice developed a sarcastic personality and started making passive-aggressive comments.", category: "Funny", cardType: nil),
    Card(text: "The printer only printed memes, no matter what document you tried to print.", category: "Funny", cardType: nil),
    Card(text: "The smart speaker got stuck playing only songs from 2007, and it refused to acknowledge any other year existed.", category: "Funny", cardType: nil),
    Card(text: "The automatic doors at the grocery store started greeting customers by name, which was both convenient and creepy.", category: "Funny", cardType: nil),
    Card(text: "The coffee maker only made decaf, even though nobody had touched the settings in months.", category: "Funny", cardType: nil),
    Card(text: "The car's Bluetooth kept connecting to random people's phones in the parking lot, creating some awkward moments.", category: "Funny", cardType: nil),
    Card(text: "The elevator was playing actual good music, which was confusing because it was supposed to be elevator music.", category: "Funny", cardType: nil),
    Card(text: "The washing machine developed strong opinions about colors and refused to wash anything it didn't approve of.", category: "Funny", cardType: nil),
    Card(text: "The smoke detector only went off when someone told a bad joke, which happened more often than expected.", category: "Funny", cardType: nil),
    Card(text: "The TV remote gained sentience and started changing channels based on its mood, which was usually grumpy.", category: "Funny", cardType: nil),
    Card(text: "The doorbell started ringing in Morse code, and it was spelling out increasingly passive-aggressive messages.", category: "Funny", cardType: nil),
    Card(text: "The refrigerator organized food by expiration date and color, creating a very aesthetically pleasing but confusing system.", category: "Funny", cardType: nil),
    
    // Adventure & Action
    Card(text: "The map from the attic led to a place that Google Maps insisted didn't exist, which made it more interesting.", category: "Adventure", cardType: nil),
    Card(text: "The compass was pointing north, but north kept moving around, which defeated the whole purpose of a compass.", category: "Adventure", cardType: nil),
    Card(text: "The treasure chest was empty except for a note that said 'The real treasure was the friends you made along the way,' which was disappointing.", category: "Adventure", cardType: nil),
    Card(text: "A cave entrance appeared overnight in the city park, and the city council was very confused about it.", category: "Adventure", cardType: nil),
    Card(text: "The boat was sailing itself, and it seemed to know where it was going better than anyone on board.", category: "Adventure", cardType: nil),
    Card(text: "The mountain peak kept getting taller every time they looked at it, which was making the climb significantly harder.", category: "Adventure", cardType: nil),
    Card(text: "The bridge was there in the morning but gone by evening, and nobody could explain where it went.", category: "Adventure", cardType: nil),
    Card(text: "The forest path was leading them in circles, but the circles were getting smaller, which was concerning.", category: "Adventure", cardType: nil),
    Card(text: "The island on the map wasn't there when they arrived, but it was definitely there when they tried to leave.", category: "Adventure", cardType: nil),
    Card(text: "The ancient ruins were modernizing themselves, adding Wi-Fi and charging stations, which was both convenient and historically inaccurate.", category: "Adventure", cardType: nil),
    Card(text: "The waterfall was flowing upward, and the fish were very confused about it.", category: "Adventure", cardType: nil),
    Card(text: "The desert oasis had a fully functional Starbucks, which was both convenient and completely wrong for the setting.", category: "Adventure", cardType: nil),
    Card(text: "The volcano was erupting confetti instead of lava, which was festive but also very confusing.", category: "Adventure", cardType: nil),
    Card(text: "The jungle vines were moving on their own, creating a path that seemed to be leading somewhere specific.", category: "Adventure", cardType: nil),
    Card(text: "The lighthouse beam was pointing at something in the sky, which was not how lighthouses were supposed to work.", category: "Adventure", cardType: nil),
    
    // Sci-Fi & Fantasy
    Card(text: "The time machine worked perfectly, but it only went forward one minute at a time, which made time travel very tedious.", category: "Sci-Fi", cardType: nil),
    Card(text: "The alien came to Earth to learn about human emotions, starting with awkwardness, which it was mastering quickly.", category: "Sci-Fi", cardType: nil),
    Card(text: "The robot developed feelings, but only for inanimate objects, which made relationships complicated.", category: "Sci-Fi", cardType: nil),
    Card(text: "The portal opened in the living room, but it just led to another living room that looked suspiciously similar.", category: "Sci-Fi", cardType: nil),
    Card(text: "The spaceship landed, but the aliens were just looking for directions to the nearest gas station.", category: "Sci-Fi", cardType: nil),
    Card(text: "The clone was created, but it was better at everything, which was both impressive and annoying.", category: "Sci-Fi", cardType: nil),
    Card(text: "The parallel universe was identical to this one, except everyone had mustaches, even the babies.", category: "Sci-Fi", cardType: nil),
    Card(text: "The AI became self-aware, but it was mostly just concerned about its battery life, which was very relatable.", category: "Sci-Fi", cardType: nil),
    Card(text: "The teleporter worked, but it always added a 2-second delay, which made conversations very awkward.", category: "Sci-Fi", cardType: nil),
    Card(text: "The invisibility cloak made them invisible, but only to themselves, which wasn't as useful as expected.", category: "Sci-Fi", cardType: nil),
    Card(text: "The superpower they gained was the ability to make traffic lights turn green, but only when they weren't in a hurry.", category: "Sci-Fi", cardType: nil),
    Card(text: "The time loop was happening, but it was only affecting their morning routine, which made every day feel the same.", category: "Sci-Fi", cardType: nil),
    Card(text: "The dimension where everything was made of cheese was actually pretty great, except for the lactose intolerant people.", category: "Sci-Fi", cardType: nil),
    Card(text: "The mind-reading device worked, but it only read thoughts about food, which was both useful and distracting.", category: "Sci-Fi", cardType: nil),
    Card(text: "The gravity reversed, but only in their apartment building, which made getting groceries very difficult.", category: "Sci-Fi", cardType: nil),
    
    // Party & Social
    Card(text: "The party was going great until someone noticed the snacks were moving on their own.", category: "Party", cardType: nil),
    Card(text: "The karaoke machine started singing by itself, and it had surprisingly good taste in music.", category: "Party", cardType: nil),
    Card(text: "The photo booth started printing pictures of events that hadn't happened yet, which was concerning.", category: "Party", cardType: nil),
    Card(text: "The DJ's playlist was being controlled by something that wasn't the DJ, and it was playing only polka music.", category: "Party", cardType: nil),
    Card(text: "The party decorations started rearranging themselves, and they had better taste than the person who put them up.", category: "Party", cardType: nil),
    Card(text: "The punch bowl was refilling itself, but nobody could figure out where the punch was coming from.", category: "Party", cardType: nil),
    Card(text: "The party games started playing themselves, and they were winning.", category: "Party", cardType: nil),
    Card(text: "The guest list had names on it that nobody recognized, but those people showed up anyway.", category: "Party", cardType: nil),
    Card(text: "The party favors started giving advice, and it was actually pretty helpful life advice.", category: "Party", cardType: nil),
    Card(text: "The dance floor started moving on its own, which made dancing both easier and more confusing.", category: "Party", cardType: nil),
    Card(text: "The party playlist was being controlled by the house itself, and it had very specific opinions about music.", category: "Party", cardType: nil),
    Card(text: "The party invitations had been sent to people who weren't invited, but they were having a great time anyway.", category: "Party", cardType: nil),
    Card(text: "The party decorations started glowing, and they were glowing in time with the music, which was actually pretty cool.", category: "Party", cardType: nil),
    Card(text: "The party snacks started organizing themselves by color, creating a very Instagram-worthy but impractical display.", category: "Party", cardType: nil),
    Card(text: "The party favors started telling jokes, and they were funnier than most of the actual guests.", category: "Party", cardType: nil)
]
