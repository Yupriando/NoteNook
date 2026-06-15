const router = require("express").Router();

const verifyToken = require("../middleware/verifyToken");

const {
  profile,
  updateProfile,
  changePassword,
  getMentors,
  getUserProfile,
  becomeMentor,
  getUserNotes,
} = require("../controllers/userController");

const upload = require("../middleware/uploadProfile");

/**
 * @swagger
 * tags:
 *   name: User
 */

/**
 * @swagger
 * /user/profile:
 *   get:
 *     summary:
 *       Get profile
 *
 *     tags:
 *       - User
 *
 *     security:
 *       - bearerAuth: []
 *
 *     responses:
 *       200:
 *         description:
 *           success
 */
router.get("/profile", verifyToken, profile);

/**
 * @swagger
 *
 * /user/profile:
 *
 *   put:
 *
 *     summary:
 *       Update profile
 *
 *     tags:
 *       - User
 *
 *     security:
 *       - bearerAuth: []
 *
 *     requestBody:
 *
 *       required: true
 *
 *       content:
 *
 *         multipart/form-data:
 *
 *           schema:
 *
 *             type: object
 *
 *             properties:
 *
 *               name:
 *                 type: string
 *
 *               phone:
 *                 type: string
 *
 *               email:
 *                 type: string
 *
 *               profile_picture:
 *
 *                 type: string
 *
 *                 format: binary
 *
 *     responses:
 *
 *       200:
 *
 *         description:
 *           Profile updated
 *
 *         content:
 *
 *           application/json:
 *
 *             schema:
 *
 *               type: object
 *
 *               properties:
 *
 *                 message:
 *
 *                   type: string
 *
 *                   example:
 *                     profile updated
 *
 *       401:
 *
 *         description:
 *           Unauthorized
 *
 *       500:
 *
 *         description:
 *           Server error
 */
router.put(
  "/profile",
  verifyToken,
  upload.single("profile_picture"),
  updateProfile,
);

/**
 * @swagger
 *
 * /user/change-password:
 *
 *   put:
 *
 *     summary:
 *       Change password
 *
 *     tags:
 *       - User
 *
 *     security:
 *
 *       - bearerAuth: []
 *
 *     requestBody:
 *
 *       required: true
 *
 *       content:
 *
 *         application/json:
 *
 *           schema:
 *
 *             type: object
 *
 *             properties:
 *
 *               oldPassword:
 *
 *                 type: string
 *
 *               newPassword:
 *
 *                 type: string
 *
 *               confirmPassword:
 *
 *                 type: string
 *
 *     responses:
 *
 *       200:
 *
 *         description:
 *           Password updated
 *
 *         content:
 *
 *           application/json:
 *
 *             schema:
 *
 *               type: object
 *
 *               properties:
 *
 *                 message:
 *
 *                   type: string
 *
 *                   example:
 *                     password updated
 *
 *       400:
 *
 *         description:
 *           Validation error
 *
 *       401:
 *
 *         description:
 *           Invalid password
 *
 *       500:
 *
 *         description:
 *           Server error
 */
router.put("/change-password", verifyToken, changePassword);

/**
 * @swagger
 *
 * /user/mentors:
 *
 *   get:
 *
 *     summary:
 *       Get mentor list
 *
 *     tags:
 *       - User
 *
 *     security:
 *
 *       - bearerAuth: []
 *
 *     responses:
 *
 *       200:
 *
 *         description:
 *           Success
 */
router.get("/mentors", verifyToken, getMentors);

/**
 * @swagger
 *
 * /user/profile/{id}:
 *   get:
 *
 *     summary: Get user profile
 *
 *     tags:
 *       - User
 *
 *     security:
 *       - bearerAuth: []
 *
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *
 *         schema:
 *           type: integer
 *
 *     responses:
 *
 *       200:
 *         description: Success
 *
 *       401:
 *         description: Unauthorized
 *
 *       404:
 *         description: User not found
 *
 *       500:
 *         description: Server error
 */
router.get("/profile/:id", verifyToken, getUserProfile);

/**
 * @swagger
 *
 * /user/become-mentor:
 *   put:
 *
 *     summary: Become mentor
 *
 *     tags:
 *       - User
 *
 *     security:
 *       - bearerAuth: []
 *
 *     responses:
 *
 *       200:
 *         description: Success
 *
 *       400:
 *         description: Already mentor
 *
 *       401:
 *         description: Unauthorized
 *
 *       500:
 *         description: Server error
 */
router.put("/become-mentor", verifyToken, becomeMentor);

/**
 * @swagger
 *
 * /user/{id}/notes:
 *   get:
 *
 *     summary: Get public notes by user
 *
 *     tags:
 *       - User
 *
 *     security:
 *       - bearerAuth: []
 *
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *
 *         schema:
 *           type: integer
 *
 *     responses:
 *
 *       200:
 *         description: Success
 *
 *       401:
 *         description: Unauthorized
 *
 *       404:
 *         description: User not found
 *
 *       500:
 *         description: Server error
 */
router.get("/:id/notes", verifyToken, getUserNotes);

module.exports = router;
