-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 05, 2026 at 05:47 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `mhs_lec`
--

-- --------------------------------------------------------

--
-- Table structure for table `bookmarks`
--

CREATE TABLE `bookmarks` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `note_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bookmarks`
--

INSERT INTO `bookmarks` (`id`, `user_id`, `note_id`, `created_at`) VALUES
(110, 9, 57, '2026-06-05 12:03:03'),
(111, 9, 55, '2026-06-05 12:03:13'),
(112, 9, 54, '2026-06-05 12:03:16'),
(113, 11, 56, '2026-06-05 12:12:15'),
(114, 11, 55, '2026-06-05 12:12:16'),
(115, 12, 57, '2026-06-05 12:14:51'),
(121, 21, 56, '2026-06-05 15:43:21');

-- --------------------------------------------------------

--
-- Table structure for table `chats`
--

CREATE TABLE `chats` (
  `id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `receiver_id` int(11) NOT NULL,
  `message` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `read_status` tinyint(1) DEFAULT 0,
  `file_url` text DEFAULT NULL,
  `file_type` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `chats`
--

INSERT INTO `chats` (`id`, `sender_id`, `receiver_id`, `message`, `created_at`, `read_status`, `file_url`, `file_type`) VALUES
(92, 10, 7, 'Hello John, do you have and recommendations for learning Flutter state management?', '2026-06-05 12:16:26', 1, NULL, NULL),
(93, 7, 10, 'I would recommend starting with Provider before exploring more advanced solutions such as Riverpod or Bloc', '2026-06-05 12:18:23', 1, NULL, NULL),
(94, 10, 7, 'Thank you. I will definitely check those out', '2026-06-05 12:22:34', 0, NULL, NULL),
(95, 11, 8, 'Hi Sarah, could you review my monthly budgeting template?', '2026-06-05 12:28:22', 1, NULL, NULL),
(96, 11, 8, NULL, '2026-06-05 12:29:30', 1, NULL, NULL),
(97, 8, 11, 'The structure is great. I recommend adding a separate category for emergency savings and tracking actual monthly expenses to better evaluate spending habits', '2026-06-05 12:30:32', 1, NULL, NULL),
(98, 8, 11, NULL, '2026-06-05 12:35:44', 1, NULL, NULL),
(99, 11, 8, 'Thank you for the detailed review, Sarah. The budget allocation chart and recommendations are very helpful. I\'ll add an Emergency Fund category and start tracking my actual monthly expenses more consistently', '2026-06-05 12:37:20', 1, NULL, NULL),
(100, 12, 9, 'I recently read your note about the 8 Golden Rules of Interface Design. The section about consistency was especially useful for my current project', '2026-06-05 12:55:18', 1, NULL, NULL),
(102, 9, 12, 'I\'m glad you found it helpful. Consistency is one of the most fundamental principles in UI/UX design because it reduces the learning curve and creates a more intuitive user experience', '2026-06-05 13:36:31', 1, NULL, NULL),
(103, 12, 9, 'I can already see how applying that principle improves the usability of my interface', '2026-06-05 13:36:46', 1, NULL, NULL),
(109, 21, 8, 'hi Sarah, could you review my monthly budgetting template?', '2026-06-05 15:45:08', 1, NULL, NULL),
(110, 21, 8, NULL, '2026-06-05 15:45:13', 1, NULL, NULL),
(111, 8, 21, 'hi Alex', '2026-06-05 15:45:25', 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `chat_files`
--

CREATE TABLE `chat_files` (
  `id` int(11) NOT NULL,
  `chat_id` int(11) NOT NULL,
  `file_url` text NOT NULL,
  `file_type` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `chat_files`
--

INSERT INTO `chat_files` (`id`, `chat_id`, `file_url`, `file_type`, `created_at`) VALUES
(17, 96, 'http://192.168.1.6:3000/uploads/chat/1780662570653.xlsx', 'file', '2026-06-05 12:29:30'),
(18, 98, 'http://192.168.1.6:3000/uploads/chat/1780662944450.png', 'image', '2026-06-05 12:35:44'),
(23, 110, 'http://192.168.1.6:3000/uploads/chat/1780674313229.png', 'image', '2026-06-05 15:45:13'),
(24, 110, 'http://192.168.1.6:3000/uploads/chat/1780674313229.xlsx', 'file', '2026-06-05 15:45:13');

-- --------------------------------------------------------

--
-- Table structure for table `comments`
--

CREATE TABLE `comments` (
  `id` int(11) NOT NULL,
  `note_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `comment` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `comments`
--

INSERT INTO `comments` (`id`, `note_id`, `user_id`, `parent_id`, `comment`, `created_at`) VALUES
(18, 56, 11, NULL, 'This budgeting guide is easy to understand and very useful for students who are managing their monthly expenses', '2026-06-05 12:12:56'),
(19, 56, 8, 18, 'Thank you, Ana. I\'m glad you found it helpful. Developing good budgeting habits early can make a significant difference in achieving long-term financial stability and reaching your financial goals', '2026-06-05 12:42:02'),
(29, 56, 21, NULL, 'good note', '2026-06-05 15:43:11'),
(30, 56, 8, 29, 'thankyou', '2026-06-05 15:43:19');

-- --------------------------------------------------------

--
-- Table structure for table `folders`
--

CREATE TABLE `folders` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `parent_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `folders`
--

INSERT INTO `folders` (`id`, `user_id`, `name`, `created_at`, `updated_at`, `parent_id`) VALUES
(13, 7, 'Mobile Hybrid Solution', '2026-06-05 04:18:29', '2026-06-05 04:18:29', NULL),
(14, 7, 'UnderStanding Flutter\'s Core Architecture', '2026-06-05 04:28:19', '2026-06-05 04:28:19', 13),
(23, 21, 'folder', '2026-06-05 15:43:47', '2026-06-05 15:43:47', NULL),
(24, 21, 'subfolder', '2026-06-05 15:43:51', '2026-06-05 15:43:51', 23);

-- --------------------------------------------------------

--
-- Table structure for table `notes`
--

CREATE TABLE `notes` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` longtext DEFAULT NULL,
  `visibility` enum('public','private') DEFAULT 'private',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `folder_id` int(11) DEFAULT NULL,
  `file_url` text DEFAULT NULL,
  `file_type` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notes`
--

INSERT INTO `notes` (`id`, `user_id`, `title`, `description`, `visibility`, `created_at`, `updated_at`, `folder_id`, `file_url`, `file_type`) VALUES
(53, 7, 'Understanding Flutter\'s Core Architecture ', 'Define the fundamental concepts of hybrid mobile development', 'public', '2026-06-05 11:32:37', '2026-06-05 11:32:37', 14, NULL, NULL),
(54, 7, 'Flutter vs FlutterFlow', 'Difference between flutter and flutterflow in aspects Development Approach, Customization, Learning Curve, Suitable Project Types, etc', 'public', '2026-06-05 11:36:58', '2026-06-05 11:36:58', 13, NULL, NULL),
(55, 8, 'Introduction to Personal Financial Planning', 'A beginner-friendly guide to managing personal finances, setting financial goals, creating budgets, and building long-term financial stability', 'public', '2026-06-05 11:46:39', '2026-06-05 11:46:39', NULL, NULL, NULL),
(56, 8, 'Budgeting Strategies for University Students', 'Practical budgeting techniques designed for university students to effectively manage income, track expenses, reduce unnecessary spending, and build healthy financial habits while balancing academic and personal needs.', 'public', '2026-06-05 11:49:26', '2026-06-05 11:49:26', NULL, NULL, NULL),
(57, 9, 'Introduction to UI/UX Design', 'This note explores Ben Shneiderman\'s Eight Golden Rules of Interface Design, a set of fundamental principles for creating user-friendly, consistent, and effective digital interfaces. Topics include consistency, usability, informative feedback, error prevention, user control, and reducing cognitive load. These principles remain widely used in modern UI/UX design to improve user experience across websites, mobile applications, and software systems.\r\n\r\nReference:\r\nhttps://socs.binus.ac.id/2016/12/22/8-golden-rules-interface-design/ ', 'public', '2026-06-05 12:02:34', '2026-06-05 12:02:42', NULL, NULL, NULL),
(66, 21, 'private note', '', 'private', '2026-06-05 15:44:16', '2026-06-05 15:44:16', 24, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `note_files`
--

CREATE TABLE `note_files` (
  `id` int(11) NOT NULL,
  `note_id` int(11) NOT NULL,
  `file_url` text NOT NULL,
  `file_type` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `note_files`
--

INSERT INTO `note_files` (`id`, `note_id`, `file_url`, `file_type`, `created_at`) VALUES
(35, 53, 'http://192.168.1.6:3000/uploads/notes/1780659157622.pptx', 'file', '2026-06-05 11:32:37'),
(36, 54, 'http://192.168.1.6:3000/uploads/notes/1780659418453.jpg', 'image', '2026-06-05 11:36:58'),
(37, 55, 'http://192.168.1.6:3000/uploads/notes/1780659999549.png', 'image', '2026-06-05 11:46:39'),
(38, 55, 'http://192.168.1.6:3000/uploads/notes/1780659999551.docx', 'file', '2026-06-05 11:46:39'),
(39, 57, 'http://192.168.1.6:3000/uploads/notes/1780660954691.pdf', 'file', '2026-06-05 12:02:34');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `role` enum('user','mentor') DEFAULT NULL,
  `profile_picture` text DEFAULT NULL,
  `bio` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `phone`, `email`, `password`, `role`, `profile_picture`, `bio`) VALUES
(7, 'John Doe', '082254746889', 'johndoe@gmail.com', '$2b$10$OOXOy5mtBHlk9n8gm2M/Gec6oFoLGvyju3TYexmShMPxMFwqmfjwS', 'mentor', 'http://192.168.1.6:3000/uploads/profile/1780633979252.jpg', 'Software Engineer and Mobile Development Mentor with over 5 years of experience in Flutter, Node.js, and RESTful API development.'),
(8, 'Sarah Wijaya', '081368914091', 'sarahwijaya@gmail.com', '$2b$10$OhUVdzQSeJSBZVWTjMLnd.aGl2tnKE6l5MWwzIlJeN7rUaxHlX1T6', 'mentor', 'http://192.168.1.6:3000/uploads/profile/1780635615966.jpg', 'Financial Analyst and Investment Mentor with over 6 years of experience in personal finance, financial planning, and investment strategies.'),
(9, 'Michael Deer', '082247123109', 'michaeldeer@gmail.com', '$2b$10$3/WBGYee890ldlN/FRu15.176ep6wo0DnlVEKUORlkAYOC/9UC5hG', 'mentor', 'http://192.168.1.6:3000/uploads/profile/1780660512051.jpg', 'Experienced UI/UX Designer specializing in user-centered design, mobile application interfaces, wireframing, prototyping, and design systems.'),
(10, 'Tom Ronald', '081321194478', 'tomronald@gmail.com', '$2b$10$r9E1eRJyaaoEcBUdmB8JuOSEyg8urkdrRak9TmfaHDQrVCuFj.hIu', 'user', 'http://192.168.1.6:3000/uploads/profile/1780661420992.png', 'Computer Science student passionate about software development, mobile applications, and emerging technologies. '),
(11, 'Ana Patricia', '082278569091', 'anapatricia@gmail.com', '$2b$10$hMMHjP/32V7yShhUrYUX5.Iz10917mnRwdbdnkJWc77cRBA2QDXjG', 'user', 'http://192.168.1.6:3000/uploads/profile/1780661525564.png', 'Business Information Systems student interested in financial literacy, investment planning, and personal development. '),
(12, 'Theo Williams', '082287831264', 'theowilliams@gmail.com', '$2b$10$4u36xqBnKqBOSpIQDX2U8.J.GVW4h2cU6osa715YKuvHU4s26JAei', 'user', 'http://192.168.1.6:3000/uploads/profile/1780661684159.png', 'Creative technology enthusiast with a strong interest in UI/UX design, product design, and digital experiences.'),
(21, 'Alex Christian', '082231167831', 'alexc@gmail.com', '$2b$10$yj2Jjq0ioiYq1V4UBEW3Y.kYx0i3ixj3KHNZLgkzWSZ3e4AC7m5dq', 'mentor', 'http://192.168.1.6:3000/uploads/profile/1780674345122.jpg', 'Computer Science Student');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bookmarks`
--
ALTER TABLE `bookmarks`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`,`note_id`),
  ADD UNIQUE KEY `unique_bookmark` (`user_id`,`note_id`),
  ADD KEY `note_id` (`note_id`);

--
-- Indexes for table `chats`
--
ALTER TABLE `chats`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sender_id` (`sender_id`),
  ADD KEY `receiver_id` (`receiver_id`);

--
-- Indexes for table `chat_files`
--
ALTER TABLE `chat_files`
  ADD PRIMARY KEY (`id`),
  ADD KEY `chat_id` (`chat_id`);

--
-- Indexes for table `comments`
--
ALTER TABLE `comments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `note_id` (`note_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `parent_id` (`parent_id`);

--
-- Indexes for table `folders`
--
ALTER TABLE `folders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `notes`
--
ALTER TABLE `notes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `fk_folder` (`folder_id`);

--
-- Indexes for table `note_files`
--
ALTER TABLE `note_files`
  ADD PRIMARY KEY (`id`),
  ADD KEY `note_id` (`note_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bookmarks`
--
ALTER TABLE `bookmarks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=122;

--
-- AUTO_INCREMENT for table `chats`
--
ALTER TABLE `chats`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=112;

--
-- AUTO_INCREMENT for table `chat_files`
--
ALTER TABLE `chat_files`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `comments`
--
ALTER TABLE `comments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `folders`
--
ALTER TABLE `folders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `notes`
--
ALTER TABLE `notes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=67;

--
-- AUTO_INCREMENT for table `note_files`
--
ALTER TABLE `note_files`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=53;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookmarks`
--
ALTER TABLE `bookmarks`
  ADD CONSTRAINT `bookmarks_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `bookmarks_ibfk_2` FOREIGN KEY (`note_id`) REFERENCES `notes` (`id`);

--
-- Constraints for table `chats`
--
ALTER TABLE `chats`
  ADD CONSTRAINT `chats_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `chats_ibfk_2` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `chat_files`
--
ALTER TABLE `chat_files`
  ADD CONSTRAINT `chat_files_ibfk_1` FOREIGN KEY (`chat_id`) REFERENCES `chats` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `comments`
--
ALTER TABLE `comments`
  ADD CONSTRAINT `comments_ibfk_1` FOREIGN KEY (`note_id`) REFERENCES `notes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `comments_ibfk_3` FOREIGN KEY (`parent_id`) REFERENCES `comments` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `folders`
--
ALTER TABLE `folders`
  ADD CONSTRAINT `folders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notes`
--
ALTER TABLE `notes`
  ADD CONSTRAINT `fk_folder` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `notes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `note_files`
--
ALTER TABLE `note_files`
  ADD CONSTRAINT `note_files_ibfk_1` FOREIGN KEY (`note_id`) REFERENCES `notes` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
