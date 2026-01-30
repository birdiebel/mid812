
# Genere
def go_players(nbCount, sexe)
    # Boucle
    (1..nbCount).each do |i|
        # User
        user = User.new
        user.email = Faker::Internet.email
        user.password = "123456"
        user.actif = true
        user.save
        puts "User #{user.id}"

        # Player
        player = Player.new
        player.user = user
        player.firstname = Faker::Name.male_first_name
        player.lastname = Faker::Name.last_name
        player.sexe = sexe
        player.dob = Faker::Date.between(from: '1955-09-23', to: '2010-09-25')
        player.save
        puts "PLayer #{i}"

        # Licence
        licence = Licence.new
        licence.player = player
        licence.num = Faker::Number.between(from: 100000, to: 999999).to_s
        licence.hcp = Faker::Number.between(from: -2.1, to: 36.4)
        licence.club = Faker::Sports::Basketball.team
        licence.save
        puts "Licence #{i}"
    end
end

def go_agecat(name, short, age_low, age_high, color, year)
    agecat = Agecat.new
    agecat.name = name
    agecat.short = short
    agecat.age_low = age_low
    agecat.age_high = age_high
    agecat.color = color
    agecat.year = year
    agecat.save
    puts "Agecat #{name}"
end

def seed_tours(name)
    # Reset datas
    Tour.delete_all
    Event.delete_all

    # Boucles
    tour1 = Tour.new
    tour1.name = "Federal Tour"
    tour1.status = :open
    tour1.actif = true
    tour1.year = 2026
    tour1.save
    puts "Tour #{tour1.name}"

    event1 = Event.new
    event1.name = "Rigenée "
    event1.status = :created
    event1.actif = true
    event1.tour = tour1
    event1.save
    puts " Event #{event1.name}"
end

# Users, players and licence
def seed_players(men, ladies)
    # Reset datas
    # Entry.delete.all
    User.delete_all
    Player.delete_all

    # Boucles
    go_players(men, 0)
    go_players(ladies, 1)
end

def seed_agecats
    # Reset datas
    Agecat.delete_all

    # Boucles
    # go_agecat("All", "A", 0, 99, "black", 2026)
    go_agecat("Junior", "J", 0, 17, "orange", 2026)
    go_agecat("Young Adult", "Y", 18, 24, "brown", 2026)
    go_agecat("Midam", "M", 25, 49, "blue", 2026)
    go_agecat("Senior", "S", 50, 99, "green", 2026)
end

def go_playercat(name, sexe, hcp_min, hcp_max, version, teebox, priority, format)
    playercat = Playercat.new
    playercat.name = name
    playercat.sexe = sexe
    playercat.hcp_min = hcp_min
    playercat.hcp_max = hcp_max
    playercat.version = version
    playercat.teebox = teebox
    playercat.priority = priority
    playercat.format = format
    playercat.save
    puts "Playercat #{name}"
    playercat
end

def seed_playercats
    # Reset datas
    Playercat.delete_all

    # Boucles
    # Federal Men
    pc = go_playercat("Federal Men", 0, -5, 14.4, "2026", "White", 1, 0)
    pc.agecats << Agecat.find_by(name: "Midam")
    pc.agecats << Agecat.find_by(name: "Senior")
    pc.save

    # Federal Ladies
    pc = go_playercat("Federal Ladies", 1, -5, 14.4, "2026", "Blue", 2, 0)
    pc.agecats << Agecat.find_by(name: "Midam")
    pc.agecats << Agecat.find_by(name: "Senior")
    pc.save

    # Young Men
    pc = go_playercat("Young Adult Men", 0, -5, 14.4, "2026", "White", 5, 0)
    pc.agecats << Agecat.find_by(name: "Young Adult")
    pc.save

    # Young Ladies
    pc = go_playercat("Young Adult Ladies", 1, -5, 14.4, "2026", "White", 6, 0)
    pc.agecats << Agecat.find_by(name: "Young Adult")
    pc.save

    # Futures Men
    pc = go_playercat("Future Men", 0, 14.5, 36.4, "2026", "Yellow", 3, 0)
    pc.agecats << Agecat.find_by(name: "Midam")
    pc.agecats << Agecat.find_by(name: "Senior")
    pc.save

    # Futures Ladies
    pc = go_playercat("Future Ladies", 1, 14.5, 36.4, "2026", "Red", 4, 0)
    pc.agecats << Agecat.find_by(name: "Midam")
    pc.agecats << Agecat.find_by(name: "Senior")
    pc.save

    # Team (bt) Serie 1 Men
    pc = go_playercat("Team (bt) Serie 1 Men", 0, -5, 18.4, "2026", "White", 7, 1)
    pc.agecats << Agecat.find_by(name: "Midam")
    pc.agecats << Agecat.find_by(name: "Senior")
    pc.save

    # Team (bt) Serie 1 Ladies
    pc = go_playercat("Team (bt) Serie 1 Ladies", 1, -5, 18.4, "2026", "Blue", 8, 1)
    pc.agecats << Agecat.find_by(name: "Midam")
    pc.agecats << Agecat.find_by(name: "Senior")
    pc.save

    # Team (bt) Serie 2 Men
    pc = go_playercat("Team (bt) Serie 2 Men", 0, 18.5, 36.4, "2026", "Yellow", 9, 1)
    pc.agecats << Agecat.find_by(name: "Midam")
    pc.agecats << Agecat.find_by(name: "Senior")
    pc.save

    # Team (bt) Serie 2 Ladies
    pc = go_playercat("Team (bt) Serie 2 Ladies", 1, 18.5, 36.4, "2026", "Red", 10, 1)
    pc.agecats << Agecat.find_by(name: "Midam")
    pc.agecats << Agecat.find_by(name: "Senior")
    pc.save
end

def seed_admin_user
    # Reset datas
    User.where(role: "admin").destroy_all

    # Admin User
    user = User.new
    user.email = "midamseries@gmail.com"
    user.password = "123456"
    user.role = "admin"
    user.actif = true
    user.save
    puts "Admin User #{user.email}"
end

def seed_club_course(club_name, course_name)
    # Club
    club = Club.new
    club.name = club_name
    club.save
    puts "Club #{club.name}"
    # Course
    course = Course.new
    course.club = club
    course.name = course_name
    course.nb_hole = 18
    course.version = "2026"
    course.save
    puts "Course #{course.name}"
    # Tees are created by after_create callback
    # course.create_tees
    # puts " Tees created"
    tee = Tee.find_by(course: course, teebox: "White")
    tee.par_str = "4,4,4,4,3,5,3,5,4,4,5,4,4,3,5,5,4,3"
    tee.stroke_str = "16,14,2,8,6,10,18,12,4,1,11,5,9,3,17,13,7,15"
    tee.dist_str = "286,339,404,370,170,483,146,490,353,367,500,323,319,163,467,483,341,139"
    tee.rating = 72.7
    tee.slope = 133
    tee.save
    puts " TEE #{tee.teebox} for course #{course.name}"

    tee = Tee.find_by(course: course, teebox: "Yellow")
    tee.par_str = "4,4,4,4,3,5,3,5,4,4,5,4,4,3,5,5,4,3"
    tee.stroke_str = "16,14,2,8,6,10,18,12,4,1,11,5,9,3,17,13,7,15"
    tee.dist_str = "270,313,342,310,160,466,145,470,360,349,470,315,309,144,435,456,306,136"
    tee.rating = 70.6
    tee.slope = 127
    tee.save
    puts " TEE #{tee.teebox} for course #{course.name}"

    tee = Tee.find_by(course: course, teebox: "Blue")
    tee.par_str = "4,4,4,4,3,5,3,5,4,4,5,4,4,3,5,5,4,3"
    tee.stroke_str = "16,14,2,8,6,10,18,12,4,1,11,5,9,3,17,13,7,15"
    tee.dist_str = "253,290,340,292,144,413,119,423,288,310,418,277,266,127,403,406,292,116"
    tee.rating = 73.1
    tee.slope = 127
    tee.save
    puts " TEE #{tee.teebox} for course #{course.name}"

    tee = Tee.find_by(course: course, teebox: "Red")
    tee.par_str = "4,4,4,4,3,5,3,5,4,4,5,4,4,3,5,5,4,3"
    tee.stroke_str = "16,14,2,8,6,10,18,12,4,1,11,5,9,3,17,13,7,15"
    tee.dist_str = "209,270,290,264,127,377,106,396,295,294,392,259,257,110,367,380,262,107"
    tee.rating = 70.8
    tee.slope = 123
    tee.save
    puts " TEE #{tee.teebox} for course #{course.name}"
end

# Seed Admin User
# seed_admin_user

# # Seed Players
# seed_players(50, 30)

# # Seed Agecats
# seed_agecats

# Seed Playercats
# seed_playercats

# Seed Tours and Events
# seed_tours("Federal Tour")
#
# Seed Rigenée Club and Course
# seed_club_course("Golf de Rigenée", "Le Chateau")
# seed_club_course("Golf de Pierpont", "Grand Pierpont")
# seed_club_course("Golf de Mérignies", "Val de Marque / Rupilly")
