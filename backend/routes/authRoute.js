const router = require("express").Router();
const verifyToken = require("../middleware/verifyToken");
const { register, login, logout } = require("../controllers/authController");

/**
 * @swagger
 * tags:
 *   name: Auth
 */

/**
 * @swagger
 * /auth/register:
 *   post:
 *     summary: Register user
 *     tags:
 *       - Auth
 *
 *     requestBody:
 *       required: true
 *
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *
 *             required:
 *               - name
 *               - phone
 *               - email
 *               - password
 *               - role
 *
 *             properties:
 *
 *               name:
 *                 type: string
 *                 example: John Doe
 *
 *               phone:
 *                 type: string
 *                 example: 08123456789
 *
 *               email:
 *                 type: string
 *                 example: john@gmail.com
 *
 *               password:
 *                 type: string
 *                 example: password123
 *
 *               role:
 *                 type: string
 *
 *                 enum:
 *                   - user
 *                   - mentor
 *
 *                 example: user
 *
 *     responses:
 *
 *       201:
 *         description: Register success
 *
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *
 *               properties:
 *
 *                 message:
 *                   type: string
 *                   example: register success
 *
 *       400:
 *         description: Validation failed
 *
 *       409:
 *         description: Email already exists
 *
 *       500:
 *         description: Server error
 */
router.post("/register", register);

/**
 * @swagger
 * /auth/login:
 *   post:
 *     summary: Login user
 *
 *     tags:
 *       - Auth
 *
 *     requestBody:
 *       required: true
 *
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *
 *             required:
 *               - email
 *               - password
 *
 *             properties:
 *
 *               email:
 *                 type: string
 *                 example: john@gmail.com
 *
 *               password:
 *                 type: string
 *                 example: password123
 *
 *     responses:
 *
 *       200:
 *         description: Login success
 *
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *
 *               properties:
 *
 *                 message:
 *                   type: string
 *                   example: login success
 *
 *                 token:
 *                   type: string
 *
 *                 user:
 *                   type: object
 *
 *                   properties:
 *
 *                     id:
 *                       type: integer
 *                       example: 1
 *
 *                     name:
 *                       type: string
 *                       example: John Doe
 *
 *                     phone:
 *                       type: string
 *                       example: 08123456789
 *
 *                     email:
 *                       type: string
 *                       example: john@gmail.com
 *
 *                     role:
 *                       type: string
 *                       example: user
 *
 *                     profile_picture:
 *                       type: string
 *                       nullable: true
 *
 *       400:
 *         description: Email and password required
 *
 *       401:
 *         description: Wrong password
 *
 *       404:
 *         description: User not found
 *
 *       500:
 *         description: Server error
 */
router.post("/login", login);

/**
 * @swagger
 * /auth/logout:
 *   post:
 *     summary: Logout user
 *
 *     tags:
 *       - Auth
 *
 *     security:
 *       - bearerAuth: []
 *
 *     responses:
 *
 *       200:
 *         description: Logout success
 *
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *
 *               properties:
 *
 *                 message:
 *                   type: string
 *                   example: logout success
 *
 *       401:
 *         description: Unauthorized
 *
 *       500:
 *         description: Server error
 */
router.post("/logout", verifyToken, logout);

module.exports = router;
