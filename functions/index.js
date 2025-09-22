const functions = require("firebase-functions");
const axios = require("axios");
const crypto = require("crypto");

// 🔑 Store these safely in Firebase environment config (not in code!)
const CHIP_API_BASE = "https://staging-api.chip-in.asia/api"; // change to prod later
const CHIP_API_KEY = functions.config().chip.apikey; 
const CHIP_API_SECRET = functions.config().chip.apisecret;

/**
 * Utility to create signature headers
 */
function createChipHeaders() {
  const epoch = Math.floor(Date.now() / 1000); // current Unix timestamp
  const checksum = crypto
    .createHmac("sha256", CHIP_API_SECRET)
    .update(epoch.toString())
    .digest("hex");

  return {
    Authorization: `Bearer ${CHIP_API_KEY}`,
    "Content-Type": "application/json",
    "x-epoch": epoch,
    "x-checksum": checksum,
  };
}

/**
 * Cloud Function to send donation via CHIP
 * Example payload from Flutter:
 * {
 *   "organizationName": "Charity A",
 *   "amount": 100,
 *   "bankAccountId": 1,
 *   "email": "donor@email.com",
 *   "reference": "donation-123"
 * }
 */
exports.sendDonation = functions.https.onCall(async (data, context) => {
  try {
    const { organizationName, amount, bankAccountId, email, reference } = data;

    if (!amount || amount <= 0) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Invalid donation amount"
      );
    }

    // 1️⃣ Create send instruction
    const res = await axios.post(
      `${CHIP_API_BASE}/send-instruction`,
      {
        bank_account_id: bankAccountId,
        amount,
        email,
        description: `Donation to ${organizationName}`,
        reference,
      },
      { headers: createChipHeaders() }
    );

    return {
      success: true,
      message: "Donation sent successfully",
      chipResponse: res.data,
    };
  } catch (error) {
    console.error("CHIP API Error:", error.response?.data || error.message);
    throw new functions.https.HttpsError(
      "internal",
      error.response?.data?.message || "Failed to send donation"
    );
  }
});
