const db = require("../config/db");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

exports.register = async (req, res) => {
  try {
    const { name, phone, email, password, role } = req.body;

    if (!name || !phone || !email || !password || !role) {
      return res.status(400).json({
        message: "all fields are required",
      });
    }

    if (password.length < 8) {
      return res.status(400).json({
        message: "password must be at least 8 characters",
      });
    }

    if (role !== "user" && role !== "mentor") {
      return res.status(400).json({
        message: "invalid role",
      });
    }

    const [existing] = await db.execute(
      `
      SELECT id
      FROM users
      WHERE email=?
      `,
      [email],
    );

    if (existing.length > 0) {
      return res.status(409).json({
        message: "email already exists",
      });
    }

    const hash = await bcrypt.hash(password, 10);

    await db.execute(
      `
      INSERT INTO users (
        name,
        phone,
        email,
        password,
        role
      )
      VALUES (?, ?, ?, ?, ?)
      `,
      [name, phone, email, hash, role],
    );

    res.status(201).json({
      message: "register success",
    });
  } catch (error) {
    console.log(error);

    res.status(500).json({
      message: "register failed",
    });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        message: "email and password are required",
      });
    }

    const [users] = await db.execute(
      `
      SELECT *
      FROM users
      WHERE email=?
      `,
      [email],
    );

    if (users.length === 0) {
      return res.status(404).json({
        message: "user not found",
      });
    }

    const user = users[0];

    const valid = await bcrypt.compare(password, user.password);

    if (!valid) {
      return res.status(401).json({
        message: "wrong password",
      });
    }

    const token = jwt.sign(
      {
        id: user.id,
        email: user.email,
        role: user.role,
      },
      process.env.JWT_SECRET,
      {
        expiresIn: "1d",
      },
    );

    res.status(200).json({
      message: "login success",
      token,
      user: {
        id: user.id,
        name: user.name,
        phone: user.phone,
        email: user.email,
        role: user.role,
        profile_picture: user.profile_picture,
      },
    });
  } catch (error) {
    console.log(error);

    res.status(500).json({
      message: "server error",
    });
  }
};

exports.logout = async (req, res) => {
  return res.status(200).json({
    message: "logout success",
  });
};
