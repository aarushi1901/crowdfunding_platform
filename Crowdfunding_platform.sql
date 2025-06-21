create database crfunding;
use crfunding;
-- 1. User table created
CREATE TABLE usersLogin (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

-- 2. Campaign categories table created
CREATE TABLE campCtg (
    ctg_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

-- 3. Campaigns table created
CREATE TABLE campaigns (
    campaign_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    creator_id INT NOT NULL,
    ctg_id INT,
    funding_goal DECIMAL(12, 2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('active', 'successful', 'failed', 'archived') DEFAULT 'active',
    FOREIGN KEY (creator_id) REFERENCES usersLogin(user_id),
    FOREIGN KEY (ctg_id) REFERENCES campCtg(ctg_id)
);

-- 4. Reward tiers table created
CREATE TABLE reward_tiers (
    tier_id INT AUTO_INCREMENT PRIMARY KEY,
    campaign_id INT NOT NULL,
    title VARCHAR(100),
    min_pledge_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id)
);

-- 5. Pledges table created
CREATE TABLE pledges (
    pledge_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    campaign_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    reward_tier_id INT,
    pledge_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES usersLogin(user_id),
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id),
    FOREIGN KEY (reward_tier_id) REFERENCES reward_tiers(tier_id)
);
-- 6. Disbursement table created
CREATE TABLE disbursements (
    disbursement_id INT AUTO_INCREMENT PRIMARY KEY,
    campaign_id INT NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    disbursed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id)
);

-- INSERT USERS
INSERT INTO usersLogin(name, email) VALUES
('Anisha Dixit', 'anisha19@gmail.com'),
('Divya Jain', 'divya2025@gmail.com'),
('Sanya Asrani', 'sanny76@yahoo.co.in'),
('Yogendra Kumar', 'yogi1925@gmail.com'),
('Esha Khanna', 'eshu@reddit.com');

-- INSERT CATEGORIES
INSERT INTO campCtg (name) VALUES ('Social Impact'), ('Art'), ('Technology');

-- INSERT CAMPAIGNS
INSERT INTO campaigns (title, creator_id, ctg_id, funding_goal, start_date, end_date) VALUES
('Clean India Green India', 1, 1, 10000, '2025-06-01', '2025-07-01'),
('Ghibli art Studio', 2, 2, 5000, '2025-06-05', '2025-07-10'),
('Smart City', 3, 3, 8000, '2025-06-10', '2025-07-15');

-- INSERT REWARD TIERS
INSERT INTO reward_tiers (campaign_id, title, min_pledge_amount) VALUES
(1, 'Namaste Sticker Pack', 10),
(1, 'Smart Hub Device - Tohfa', 100),
(2, 'Digital Artbook', 15),
(2, 'Printed Book - Special', 50),
(3, 'Personal thankyou', 5),
(3, 'Aapka naam hamari website', 30);

-- INSERT PLEDGES
INSERT INTO pledges (user_id, campaign_id, amount, reward_tier_id) VALUES
(2, 1, 100.00, 2),
(3, 1, 10.00, 1),
(4, 2, 15.00, 3),
(5, 2, 50.00, 4),
(1, 2, 15.00, 3),
(2, 3, 5.00, 5),
(3, 3, 30.00, 6),
(4, 3, 5.00, 5),
(1, 1, 100.00, 2),
(5, 1, 10.00, 1);
INSERT INTO disbursements (campaign_id, amount) VALUES
(1, 200.00),
(2, 120.00); 

-- SAMPLE QUERIES

-- 1. Top 5 campaigns with highest total funding
SELECT c.title, SUM(p.amount) AS total_funded
FROM campaigns c
JOIN pledges p ON c.campaign_id = p.campaign_id
GROUP BY c.campaign_id
ORDER BY total_funded DESC
LIMIT 5;

-- 2. Most Active Backers
SELECT u.name, COUNT(p.pledge_id) AS total_pledges
FROM usersLogin u
JOIN pledges p ON u.user_id = p.user_id
GROUP BY u.user_id
ORDER BY total_pledges DESC;

-- 3. Show each user’s total contribution amount
SELECT u.name, u.email, SUM(p.amount) AS total_pledged
FROM usersLogin u
JOIN pledges p ON u.user_id = p.user_id
GROUP BY u.user_id
ORDER BY total_pledged DESC;

-- 4. How many backers selected each reward tier
SELECT rt.title, COUNT(p.pledge_id) AS backers
FROM reward_tiers rt
LEFT JOIN pledges p ON rt.tier_id = p.reward_tier_id
GROUP BY rt.tier_id;

-- 5. Query to view disbursement 
SELECT d.disbursement_id,c.title AS campaign_title,d.amount,d.disbursed_at
FROM disbursements d
JOIN campaigns c ON d.campaign_id = c.campaign_id;

-- TRIGGER (bonus)
DELIMITER //
CREATE TRIGGER update_campaign_status
AFTER INSERT ON pledges
FOR EACH ROW
BEGIN
    DECLARE total_pledged DECIMAL(12,2);
    SELECT SUM(amount) INTO total_pledged
    FROM pledges
    WHERE campaign_id = NEW.campaign_id;

    UPDATE campaigns
    SET status = 'successful'
    WHERE campaign_id = NEW.campaign_id
    AND total_pledged >= funding_goal;
END;
//
DELIMITER ;
