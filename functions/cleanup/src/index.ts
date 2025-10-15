import {onSchedule} from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";

admin.initializeApp();

// 🧹 Deletes notifications older than 7 days
export const deleteOldNotifications = onSchedule(
  "every 24 hours",
  async () => {
    const db = admin.firestore();
    const now = new Date();
    const cutoff = new Date(
      now.getTime() - 7 * 24 * 60 * 60 * 1000
    ); // 7 days ago

    const oldNotifications = await db
      .collection("notifications")
      .where("timestamp", "<", cutoff)
      .get();

    if (oldNotifications.empty) {
      console.log("No old notifications to delete.");
      return;
    }

    const batch = db.batch();
    oldNotifications.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();

    console.log(`🧹 Deleted ${oldNotifications.size} old notifications.`);
  }
);
