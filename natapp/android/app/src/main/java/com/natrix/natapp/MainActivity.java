package com.natrix.natapp;
import android.app.NotificationManager;
import android.content.Context;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    private void closeAllNotifications() {
        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.cancelAll();
    }
}
