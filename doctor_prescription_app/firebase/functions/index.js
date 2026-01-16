/**
 * Firebase Cloud Functions for Doctor Prescription App
 * 
 * These functions handle:
 * 1. Sending push notifications when pharmacy alerts are created
 * 2. Optional: Scheduled cleanup of old alerts
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * Triggered when a new pharmacy alert is added to Firestore
 * Sends a push notification to all devices subscribed to 'pharmacy' topic
 */
exports.sendPharmacyNotification = functions.firestore
  .document('pharmacy_alerts/{alertId}')
  .onCreate(async (snap, context) => {
    const alert = snap.data();
    
    const message = {
      notification: {
        title: '🔔 Doctor Alert',
        body: alert.message || 'Doctor calling pharmacist – please come',
      },
      data: {
        alertId: context.params.alertId,
        type: 'pharmacy_alert',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      topic: 'pharmacy',
      android: {
        priority: 'high',
        notification: {
          channelId: 'high_importance_channel',
          priority: 'high',
          sound: 'default',
        },
      },
    };

    try {
      const response = await admin.messaging().send(message);
      console.log('Notification sent successfully:', response);
      
      // Update the alert document with notification status
      await snap.ref.update({
        notificationSent: true,
        notificationSentAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      return response;
    } catch (error) {
      console.error('Error sending notification:', error);
      throw error;
    }
  });

/**
 * Mark alert as read
 * Can be called by pharmacy app when alert is acknowledged
 */
exports.markAlertRead = functions.https.onCall(async (data, context) => {
  const { alertId } = data;
  
  if (!alertId) {
    throw new functions.https.HttpsError('invalid-argument', 'Alert ID is required');
  }
  
  try {
    await admin.firestore()
      .collection('pharmacy_alerts')
      .doc(alertId)
      .update({
        isRead: true,
        readAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    
    return { success: true };
  } catch (error) {
    console.error('Error marking alert as read:', error);
    throw new functions.https.HttpsError('internal', 'Failed to mark alert as read');
  }
});

/**
 * Scheduled function to clean up old alerts (runs daily)
 */
exports.cleanupOldAlerts = functions.pubsub
  .schedule('0 0 * * *') // Every day at midnight
  .timeZone('Asia/Kolkata')
  .onRun(async (context) => {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - 30); // Delete alerts older than 30 days
    
    const snapshot = await admin.firestore()
      .collection('pharmacy_alerts')
      .where('sentAt', '<', cutoffDate)
      .get();
    
    const batch = admin.firestore().batch();
    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });
    
    await batch.commit();
    console.log(`Deleted ${snapshot.docs.length} old alerts`);
    
    return null;
  });
