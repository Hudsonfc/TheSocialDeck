//
//  RiddleMeThisCards.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation

let allRiddleMeThisCards: [Card] = [
    // Classic Riddles
    Card(text: "I speak without a mouth and hear without ears. I have no body, but I come alive with wind. What am I?", category: "Classic", correctAnswer: "An echo"),
    Card(text: "The more you take, the more you leave behind. What am I?", category: "Classic", correctAnswer: "Footsteps"),
    Card(text: "I have cities, but no houses. I have mountains, but no trees. I have water, but no fish. What am I?", category: "Classic", correctAnswer: "A map"),
    Card(text: "What has keys but no locks, space but no room, and you can enter but not go inside?", category: "Classic", correctAnswer: "A keyboard"),
    Card(text: "I'm tall when I'm young, and short when I'm old. What am I?", category: "Classic", correctAnswer: "A candle"),
    Card(text: "What has hands but can't clap?", category: "Classic", correctAnswer: "A clock"),
    Card(text: "I'm found in the ground but not dirt. I can be a rock, a gem, or metal. What am I?", category: "Classic", correctAnswer: "Ore"),
    Card(text: "The person who makes it, sells it. The person who buys it, never uses it. The person who uses it, never knows they're using it. What is it?", category: "Classic", correctAnswer: "A coffin"),
    Card(text: "What goes up and never comes down?", category: "Classic", correctAnswer: "Your age"),
    Card(text: "I'm light as a feather, but the strongest person can't hold me for more than a few minutes. What am I?", category: "Classic", correctAnswer: "Breath"),
    
    // Logic Riddles
    Card(text: "A man is looking at a photograph of someone. His friend asks who it is. The man replies, 'Brothers and sisters, I have none. But that man's father is my father's son.' Who is in the photograph?", category: "Logic", correctAnswer: "His son"),
    Card(text: "A rooster lays an egg on top of a barn roof. Which way does it roll?", category: "Logic", correctAnswer: "Roosters don't lay eggs"),
    Card(text: "There are three houses. One is red, one is blue, and one is white. If the red house is to the left of the house in the middle, and the blue house is to the right of the house in the middle, where is the white house?", category: "Logic", correctAnswer: "In Washington, D.C."),
    Card(text: "A man walks into a bar and asks for a glass of water. The bartender pulls out a gun and points it at him. The man says 'thank you' and walks out. Why?", category: "Logic", correctAnswer: "The man had hiccups"),
    Card(text: "What belongs to you but others use it more than you do?", category: "Logic", correctAnswer: "Your name"),
    Card(text: "I am taken from a mine and shut up in a wooden case, from which I am never released, and yet I am used by almost everyone. What am I?", category: "Logic", correctAnswer: "Pencil lead"),
    Card(text: "The more there is, the less you see. What is it?", category: "Logic", correctAnswer: "Darkness"),
    Card(text: "What comes once in a minute, twice in a moment, but never in a thousand years?", category: "Logic", correctAnswer: "The letter M"),
    
    // Wordplay Riddles
    Card(text: "What word is spelled incorrectly in every single dictionary?", category: "Wordplay", correctAnswer: "Incorrectly"),
    Card(text: "What starts with 'e' and ends with 'e' but only has one letter in it?", category: "Wordplay", correctAnswer: "An envelope"),
    Card(text: "What has four wheels and flies?", category: "Wordplay", correctAnswer: "A garbage truck"),
    Card(text: "What word becomes shorter when you add two letters to it?", category: "Wordplay", correctAnswer: "Short"),
    Card(text: "I am a word of five letters. People eat me. If you remove my first letter, I become a form of energy. If you remove my first two letters, I become an animal. If you remove my first and last letters, I become a type of music. What am I?", category: "Wordplay", correctAnswer: "Wheat"),
    Card(text: "What building has the most stories?", category: "Wordplay", correctAnswer: "A library"),
    Card(text: "What has a neck but no head?", category: "Wordplay", correctAnswer: "A bottle"),
    
    // Mystery Riddles
    Card(text: "I'm always hungry, I must always be fed. The finger I touch will soon turn red. What am I?", category: "Mystery", correctAnswer: "Fire"),
    Card(text: "What can travel around the world while staying in a corner?", category: "Mystery", correctAnswer: "A stamp"),
    Card(text: "I have a head and a tail, but no body. What am I?", category: "Mystery", correctAnswer: "A coin"),
    Card(text: "What has a face but cannot see?", category: "Mystery", correctAnswer: "A clock"),
    Card(text: "I can be cracked, made, told, and played. What am I?", category: "Mystery", correctAnswer: "A joke"),
    Card(text: "I'm full of holes but still hold water. What am I?", category: "Mystery", correctAnswer: "A sponge"),
    Card(text: "What gets wetter and wetter the more it dries?", category: "Mystery", correctAnswer: "A towel"),
    
    // Nature Riddles
    Card(text: "I fall but I never get hurt. I pour but I'm not a jug. I help plants grow big and tall. What am I?", category: "Nature", correctAnswer: "Rain"),
    Card(text: "I'm always running but never get tired. I have a mouth but never talk. I have a bed but never sleep. What am I?", category: "Nature", correctAnswer: "A river"),
    Card(text: "I'm born in water but when I die I die because of water. What am I?", category: "Nature", correctAnswer: "Ice"),
    Card(text: "I have branches but no fruit, trunk, or leaves. What am I?", category: "Nature", correctAnswer: "A bank"),
    Card(text: "The more of me you take, the more you leave behind. What am I?", category: "Nature", correctAnswer: "Footsteps"),
    
    // Everyday Objects
    Card(text: "I have keys but no locks. I have space but no room. You can enter but not go inside. What am I?", category: "Objects", correctAnswer: "A keyboard"),
    Card(text: "I'm used to write, but I'm not a pen. I can be erased, but I'm not a mistake. What am I?", category: "Objects", correctAnswer: "A pencil"),
    Card(text: "I have a ring but no finger. What am I?", category: "Objects", correctAnswer: "A telephone"),
    Card(text: "What has a thumb and four fingers but is not alive?", category: "Objects", correctAnswer: "A glove"),
    Card(text: "I'm a box that holds keys without locks, yet my keys can unlock your soul. What am I?", category: "Objects", correctAnswer: "A piano"),
    Card(text: "What has one eye but can't see?", category: "Objects", correctAnswer: "A needle"),
    Card(text: "I have a spine but no bones. What am I?", category: "Objects", correctAnswer: "A book"),
    
    // Time & Numbers
    Card(text: "What is always in front of you but can't be seen?", category: "Time", correctAnswer: "The future"),
    Card(text: "What comes before but is never found?", category: "Time", correctAnswer: "Never"),
    
    // Food Riddles
    Card(text: "I'm yellow and curved, monkeys love me. What am I?", category: "Food", correctAnswer: "A banana"),
    Card(text: "I'm round, red, and sometimes green. I'm a fruit that's also a color. What am I?", category: "Food", correctAnswer: "An apple"),
    Card(text: "I'm white and you drink me. I come from cows. What am I?", category: "Food", correctAnswer: "Milk"),
    Card(text: "I'm a vegetable that's green and looks like a tree. What am I?", category: "Food", correctAnswer: "Broccoli"),
    Card(text: "I'm sweet and come in bars. I'm a treat that kids love. What am I?", category: "Food", correctAnswer: "Chocolate"),
    
    // Animal Riddles
    Card(text: "I'm a bird that can't fly, but I can swim really well. What am I?", category: "Animals", correctAnswer: "A penguin"),
    Card(text: "I'm the king of the jungle, but I'm not actually from the jungle. What am I?", category: "Animals", correctAnswer: "A lion"),
    Card(text: "I'm black and white, and I'm known for being stinky. What am I?", category: "Animals", correctAnswer: "A skunk"),
    Card(text: "I'm slow and carry my home on my back. What am I?", category: "Animals", correctAnswer: "A snail"),
    Card(text: "I have a trunk but I'm not a tree. I'm the largest land animal. What am I?", category: "Animals", correctAnswer: "An elephant"),
    Card(text: "I'm known for having nine lives. What am I?", category: "Animals", correctAnswer: "A cat"),
    Card(text: "I hop around and I'm known for my pouch. What am I?", category: "Animals", correctAnswer: "A kangaroo"),
    
    // Body Parts
    Card(text: "I help you see, but I can't see myself. What am I?", category: "Body", correctAnswer: "An eye"),
    Card(text: "You have two of me, and I help you hear. What am I?", category: "Body", correctAnswer: "An ear"),
    Card(text: "You use me to smell, and I'm in the middle of your face. What am I?", category: "Body", correctAnswer: "A nose"),
    
    // Transportation
    Card(text: "I have two wheels and you pedal me. What am I?", category: "Transportation", correctAnswer: "A bicycle"),
    Card(text: "I fly in the sky and have wings, but I'm not a bird. What am I?", category: "Transportation", correctAnswer: "An airplane"),
    Card(text: "I travel on tracks and make a choo-choo sound. What am I?", category: "Transportation", correctAnswer: "A train"),
    
    // Sports & Games
    Card(text: "I'm round and you kick me. I'm used in a popular sport. What am I?", category: "Sports", correctAnswer: "A soccer ball"),
    Card(text: "I'm a game you play with rackets and a net. What am I?", category: "Sports", correctAnswer: "Tennis"),
    Card(text: "You bounce me and try to put me through a hoop. What am I?", category: "Sports", correctAnswer: "A basketball"),
    
    // Weather & Sky
    Card(text: "I appear after rain in the sky. I'm colorful and curved. What am I?", category: "Nature", correctAnswer: "A rainbow"),
    Card(text: "I'm hot and bright. I shine during the day. What am I?", category: "Nature", correctAnswer: "The sun"),
    Card(text: "I'm white and fluffy, and I float in the sky. What am I?", category: "Nature", correctAnswer: "A cloud"),
    Card(text: "I twinkle in the night sky. What am I?", category: "Nature", correctAnswer: "A star"),
    
    // More Classic Riddles
    Card(text: "The more you take away, the larger I become. What am I?", category: "Classic", correctAnswer: "A hole"),
    Card(text: "I'm seen in water but I'm not wet. What am I?", category: "Classic", correctAnswer: "A reflection"),
    Card(text: "I'm always coming but never arrive. What am I?", category: "Classic", correctAnswer: "Tomorrow"),
    Card(text: "I have legs but can't walk. What am I?", category: "Classic", correctAnswer: "A chair"),
    Card(text: "I have no beginning, no end, and no middle. What am I?", category: "Classic", correctAnswer: "A circle"),
    Card(text: "I'm not alive, but I grow. I don't have lungs, but I need air. What am I?", category: "Classic", correctAnswer: "Fire"),
    
    // More Wordplay
    Card(text: "What has a bottom at the top?", category: "Wordplay", correctAnswer: "Your legs"),
    Card(text: "I'm tall when I'm sitting, but short when I'm standing. What am I?", category: "Wordplay", correctAnswer: "A dog"),
    Card(text: "What can you break without touching it?", category: "Wordplay", correctAnswer: "A promise"),
    Card(text: "What has words but never speaks?", category: "Wordplay", correctAnswer: "A dictionary"),
    Card(text: "I'm an odd number. Take away a letter and I become even. What number am I?", category: "Wordplay", correctAnswer: "Seven"),
    
    // More Mystery
    Card(text: "I'm invisible but I'm everywhere. You can't see me but you know I'm there. What am I?", category: "Mystery", correctAnswer: "Air"),
    Card(text: "I have no legs but I can travel far. I have no mouth but I can make sounds. What am I?", category: "Mystery", correctAnswer: "Wind"),
    Card(text: "I'm not alive, but I can die. What am I?", category: "Mystery", correctAnswer: "A battery"),
    Card(text: "I have a heart that doesn't beat. What am I?", category: "Mystery", correctAnswer: "An artichoke"),
    
    // More Objects
    Card(text: "I have teeth but I can't bite. What am I?", category: "Objects", correctAnswer: "A comb"),
    Card(text: "I'm made of glass but you can't see through me clearly. You look at yourself in me. What am I?", category: "Objects", correctAnswer: "A mirror"),
    Card(text: "I'm long and thin. I help you see better. What am I?", category: "Objects", correctAnswer: "Glasses"),
    Card(text: "I open but never close. I'm on your head. What am I?", category: "Objects", correctAnswer: "An umbrella"),
    Card(text: "I have pages but I'm not a book. I help you stay clean. What am I?", category: "Objects", correctAnswer: "A calendar"),
    Card(text: "I'm round and you bounce me. I'm used in many sports. What am I?", category: "Objects", correctAnswer: "A ball"),
    
    // 100+ additional riddles
    Card(text: "I have a head, a tail, but no body. What am I?", category: "Classic", correctAnswer: "A coin"),
    Card(text: "What can you hold without ever touching?", category: "Classic", correctAnswer: "A conversation"),
    Card(text: "I'm not alive, but I can grow. I don't have lungs, but I need air. I don't have a mouth, but water kills me. What am I?", category: "Classic", correctAnswer: "Fire"),
    Card(text: "What disappears as soon as you say its name?", category: "Classic", correctAnswer: "Silence"),
    Card(text: "I'm always in front of you but can't be seen. What am I?", category: "Classic", correctAnswer: "The future"),
    Card(text: "What has 13 hearts but no other organs?", category: "Classic", correctAnswer: "A deck of cards"),
    Card(text: "I have wings but I'm not a bird. I'm found in the morning dew. What am I?", category: "Classic", correctAnswer: "A butterfly"),
    Card(text: "What gets bigger the more you take from it?", category: "Classic", correctAnswer: "A hole"),
    Card(text: "I'm not a bird but I have feathers. I'm not a fish but I love water. What am I?", category: "Classic", correctAnswer: "A pen"),
    Card(text: "What has a face and two hands but no arms or legs?", category: "Classic", correctAnswer: "A clock"),
    
    Card(text: "What word is always pronounced wrong?", category: "Wordplay", correctAnswer: "Wrong"),
    Card(text: "What has ears but cannot hear?", category: "Wordplay", correctAnswer: "A cornfield"),
    Card(text: "What has a head and a tail but no body?", category: "Wordplay", correctAnswer: "A coin"),
    Card(text: "What month has 28 days?", category: "Wordplay", correctAnswer: "All of them"),
    Card(text: "What can run but never walks, has a mouth but never talks?", category: "Wordplay", correctAnswer: "A river"),
    Card(text: "What breaks yet never falls, and what falls yet never breaks?", category: "Wordplay", correctAnswer: "Day breaks, night falls"),
    Card(text: "What has hands but can't hold anything?", category: "Wordplay", correctAnswer: "A clock"),
    Card(text: "What goes through cities and fields but never moves?", category: "Wordplay", correctAnswer: "A road"),
    Card(text: "What has a thumb and four fingers but isn't alive?", category: "Wordplay", correctAnswer: "A glove"),
    Card(text: "What gets smaller when you add to it?", category: "Wordplay", correctAnswer: "A hole"),
    
    Card(text: "I'm green and brown, and I'm home to many creatures. What am I?", category: "Nature", correctAnswer: "A tree"),
    Card(text: "I'm white when dirty and black when clean. What am I?", category: "Nature", correctAnswer: "A blackboard"),
    Card(text: "I fall in autumn and am crunchy underfoot. What am I?", category: "Nature", correctAnswer: "A leaf"),
    Card(text: "I'm frozen water that falls from the sky in winter. What am I?", category: "Nature", correctAnswer: "Snow"),
    Card(text: "I'm a body of water that's smaller than an ocean. What am I?", category: "Nature", correctAnswer: "A sea or lake"),
    Card(text: "I'm hot and I rise from the ground. I can destroy forests. What am I?", category: "Nature", correctAnswer: "Lava or volcano"),
    Card(text: "I'm cold and I fall from the sky. I'm needed for plants to grow. What am I?", category: "Nature", correctAnswer: "Rain"),
    Card(text: "I'm a season when flowers bloom and birds sing. What am I?", category: "Nature", correctAnswer: "Spring"),
    Card(text: "I'm a place where the land meets the sea. You build sandcastles on me. What am I?", category: "Nature", correctAnswer: "A beach"),
    Card(text: "I'm a tall landform that reaches toward the sky. What am I?", category: "Nature", correctAnswer: "A mountain"),
    
    Card(text: "I'm small, red, and I have a pit. I'm a summer fruit. What am I?", category: "Food", correctAnswer: "A cherry"),
    Card(text: "I'm orange and grow underground. Rabbits love me. What am I?", category: "Food", correctAnswer: "A carrot"),
    Card(text: "I'm long and yellow. I'm a tropical fruit. Monkeys love me. What am I?", category: "Food", correctAnswer: "A banana"),
    Card(text: "I'm round, red, and you put me on pizza. What am I?", category: "Food", correctAnswer: "Tomato"),
    Card(text: "I'm white and you spread me on bread. I come from milk. What am I?", category: "Food", correctAnswer: "Butter"),
    Card(text: "I'm brown and sweet. I'm used in desserts. What am I?", category: "Food", correctAnswer: "Chocolate"),
    Card(text: "I'm a green vegetable that looks like a small tree. What am I?", category: "Food", correctAnswer: "Broccoli"),
    Card(text: "I'm round and you put ketchup on me. I'm a fast food favorite. What am I?", category: "Food", correctAnswer: "A burger"),
    Card(text: "I'm made from potatoes and you eat me with ketchup. What am I?", category: "Food", correctAnswer: "French fries"),
    Card(text: "I'm a fruit that's also a color. I'm round and crunchy. What am I?", category: "Food", correctAnswer: "An apple"),
    
    Card(text: "I have stripes and I'm fast. I'm the king of the jungle. What am I?", category: "Animals", correctAnswer: "A tiger"),
    Card(text: "I'm a bird that says 'Who'. I come out at night. What am I?", category: "Animals", correctAnswer: "An owl"),
    Card(text: "I'm a sea creature with eight arms. What am I?", category: "Animals", correctAnswer: "An octopus"),
    Card(text: "I'm a furry animal that likes honey. I sleep in winter. What am I?", category: "Animals", correctAnswer: "A bear"),
    Card(text: "I'm a bird that cannot fly but I can run very fast. What am I?", category: "Animals", correctAnswer: "An ostrich"),
    Card(text: "I'm a sea creature with a shell. I pinch with my claws. What am I?", category: "Animals", correctAnswer: "A crab"),
    Card(text: "I'm green and I hop. I live in ponds. What am I?", category: "Animals", correctAnswer: "A frog"),
    Card(text: "I'm a insect that glows at night. What am I?", category: "Animals", correctAnswer: "A firefly"),
    Card(text: "I'm a mammal that flies at night. I use sound to see. What am I?", category: "Animals", correctAnswer: "A bat"),
    Card(text: "I'm a sea creature with a spiral shell. What am I?", category: "Animals", correctAnswer: "A snail"),
    
    Card(text: "I have a sharp point and I help you write. I can be erased. What am I?", category: "Objects", correctAnswer: "A pencil"),
    Card(text: "I have a blade but I don't cut. I spread butter. What am I?", category: "Objects", correctAnswer: "A butter knife"),
    Card(text: "I'm full of pages and you read me. What am I?", category: "Objects", correctAnswer: "A book"),
    Card(text: "I have numbers and hands. I tell you the time. What am I?", category: "Objects", correctAnswer: "A clock"),
    Card(text: "I'm a box that keeps things cold. What am I?", category: "Objects", correctAnswer: "A refrigerator"),
    Card(text: "I have a screen and keys. You use me to work. What am I?", category: "Objects", correctAnswer: "A computer"),
    Card(text: "I'm round and you sit on me. I have four legs. What am I?", category: "Objects", correctAnswer: "A chair"),
    Card(text: "I'm soft and you rest your head on me at night. What am I?", category: "Objects", correctAnswer: "A pillow"),
    Card(text: "I have a handle and you use me when it rains. What am I?", category: "Objects", correctAnswer: "An umbrella"),
    Card(text: "I'm used to open doors. I'm often made of metal. What am I?", category: "Objects", correctAnswer: "A key"),
    
    Card(text: "I'm something you can hold but not pick up. What am I?", category: "Logic", correctAnswer: "Your breath"),
    Card(text: "What can you catch but not throw?", category: "Logic", correctAnswer: "A cold"),
    Card(text: "I have a heart that doesn't beat. I have a bed but never sleep. What am I?", category: "Logic", correctAnswer: "A river"),
    Card(text: "What can you give someone that they must give back?", category: "Logic", correctAnswer: "Your word"),
    Card(text: "What has teeth but can't eat?", category: "Logic", correctAnswer: "A comb"),
    Card(text: "What has one eye but can't see?", category: "Logic", correctAnswer: "A needle"),
    Card(text: "What has many keys but can't open a single lock?", category: "Logic", correctAnswer: "A piano"),
    Card(text: "What gets sharper the more you use it?", category: "Logic", correctAnswer: "Your mind"),
    Card(text: "What can travel the world while staying in a corner?", category: "Logic", correctAnswer: "A stamp"),
    Card(text: "What has a tail and a head but no body?", category: "Logic", correctAnswer: "A coin"),
    
    Card(text: "I'm in your head but I'm not your brain. I help you remember. What am I?", category: "Mystery", correctAnswer: "Your memory"),
    Card(text: "I'm not alive but I can die. I need to be fed. What am I?", category: "Mystery", correctAnswer: "A battery"),
    Card(text: "I'm in the middle of water but I'm not wet. What am I?", category: "Mystery", correctAnswer: "The letter T"),
    Card(text: "I'm in the middle of Paris and at the end of the universe. What am I?", category: "Mystery", correctAnswer: "The letter R"),
    Card(text: "I'm at the beginning of nothing and the end of time. What am I?", category: "Mystery", correctAnswer: "The letter E"),
    Card(text: "I have a face and hands but no arms. I tell you the time. What am I?", category: "Mystery", correctAnswer: "A clock"),
    Card(text: "I'm light as a feather yet the strongest can't hold me long. What am I?", category: "Mystery", correctAnswer: "Breath"),
    Card(text: "I have a neck but no head. I have a body but no arms. What am I?", category: "Mystery", correctAnswer: "A bottle"),
    Card(text: "I'm seen in the dark but never in light. I'm in the day but not the night. What am I?", category: "Mystery", correctAnswer: "The letter D"),
    Card(text: "I'm in your hand but you can't feel me. I'm in your words but you can't see me. What am I?", category: "Mystery", correctAnswer: "The letter I"),
    
    Card(text: "I'm round and you dribble me. I'm orange. What sport am I used in?", category: "Sports", correctAnswer: "Basketball"),
    Card(text: "I'm white and you hit me with a bat. What sport am I used in?", category: "Sports", correctAnswer: "Baseball"),
    Card(text: "I'm black and white. You kick me on a field. What am I?", category: "Sports", correctAnswer: "A soccer ball"),
    Card(text: "I'm a net sport with a shuttlecock. What am I?", category: "Sports", correctAnswer: "Badminton"),
    Card(text: "You hit me over a net with your hands. What sport am I?", category: "Sports", correctAnswer: "Volleyball"),
    Card(text: "I'm a stick you use to hit a ball on grass. What sport am I from?", category: "Sports", correctAnswer: "Golf"),
    Card(text: "I'm frozen water where you slide and skate. What am I?", category: "Sports", correctAnswer: "An ice rink"),
    Card(text: "I'm a lane where you swim laps. What am I?", category: "Sports", correctAnswer: "A swimming pool"),
    Card(text: "You ride me and I have two wheels. What am I?", category: "Sports", correctAnswer: "A bicycle"),
    Card(text: "I'm a oval ball you throw. What sport am I used in?", category: "Sports", correctAnswer: "Football"),
    
    Card(text: "I have four wheels and an engine. I take you places. What am I?", category: "Transportation", correctAnswer: "A car"),
    Card(text: "I have two wheels and a motor. I'm faster than a bike. What am I?", category: "Transportation", correctAnswer: "A motorcycle"),
    Card(text: "I'm big and yellow. I take kids to school. What am I?", category: "Transportation", correctAnswer: "A school bus"),
    Card(text: "I run on tracks underground. I'm found in big cities. What am I?", category: "Transportation", correctAnswer: "A subway"),
    Card(text: "I'm a boat that goes under the water. What am I?", category: "Transportation", correctAnswer: "A submarine"),
    Card(text: "I have a big engine and I fly in the sky. What am I?", category: "Transportation", correctAnswer: "An airplane"),
    Card(text: "I'm a vehicle that sails on the ocean. What am I?", category: "Transportation", correctAnswer: "A ship"),
    Card(text: "I have a loud siren and flashing lights. I help in emergencies. What am I?", category: "Transportation", correctAnswer: "An ambulance"),
    Card(text: "I'm long and I have many cars. I run on railroad tracks. What am I?", category: "Transportation", correctAnswer: "A train"),
    Card(text: "I have rotors and I can hover. What am I?", category: "Transportation", correctAnswer: "A helicopter"),
    
    Card(text: "You have two of me. I help you see the world. What am I?", category: "Body", correctAnswer: "Eyes"),
    Card(text: "I'm in your mouth and I help you chew. What am I?", category: "Body", correctAnswer: "Teeth"),
    Card(text: "I pump blood through your body. What am I?", category: "Body", correctAnswer: "Your heart"),
    Card(text: "I'm at the end of your arm. I have five digits. What am I?", category: "Body", correctAnswer: "A hand"),
    Card(text: "I'm on your face and I help you smell. What am I?", category: "Body", correctAnswer: "Your nose"),
    Card(text: "I'm the bone that protects your brain. What am I?", category: "Body", correctAnswer: "Your skull"),
    Card(text: "I'm in your chest and you use me to breathe. What am I?", category: "Body", correctAnswer: "Your lungs"),
    Card(text: "I'm at the tip of your finger. You paint me. What am I?", category: "Body", correctAnswer: "A fingernail"),
    Card(text: "I'm the joint that bends in your arm. What am I?", category: "Body", correctAnswer: "Your elbow"),
    Card(text: "I'm the joint that connects your leg to your foot. What am I?", category: "Body", correctAnswer: "Your ankle"),
    
    Card(text: "I'm the opposite of the past. You never quite reach me. What am I?", category: "Time", correctAnswer: "The future"),
    Card(text: "I come once in a minute, twice in a moment, but never in a thousand years. What am I?", category: "Time", correctAnswer: "The letter M"),
    Card(text: "I have 12 faces and 12 hands. I tell you the time. What am I?", category: "Time", correctAnswer: "A clock"),
    Card(text: "I'm the first thing you see when you wake up. What am I?", category: "Time", correctAnswer: "Morning"),
    Card(text: "I'm the time when the sun goes down. What am I?", category: "Time", correctAnswer: "Dusk or evening"),
    Card(text: "I'm 60 seconds long. What am I?", category: "Time", correctAnswer: "A minute"),
    Card(text: "I'm made of 7 days. What am I?", category: "Time", correctAnswer: "A week"),
    Card(text: "I'm the day before today. What am I?", category: "Time", correctAnswer: "Yesterday"),
    Card(text: "I'm the day after today. What am I?", category: "Time", correctAnswer: "Tomorrow"),
    Card(text: "I have 365 or 366 days. What am I?", category: "Time", correctAnswer: "A year"),
]
