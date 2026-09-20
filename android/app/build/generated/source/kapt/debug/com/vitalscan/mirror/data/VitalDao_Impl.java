package com.vitalscan.mirror.data;

import android.database.Cursor;
import androidx.annotation.NonNull;
import androidx.room.CoroutinesRoom;
import androidx.room.EntityDeletionOrUpdateAdapter;
import androidx.room.EntityInsertionAdapter;
import androidx.room.RoomDatabase;
import androidx.room.RoomSQLiteQuery;
import androidx.room.SharedSQLiteStatement;
import androidx.room.util.CursorUtil;
import androidx.room.util.DBUtil;
import androidx.sqlite.db.SupportSQLiteStatement;
import java.lang.Class;
import java.lang.Exception;
import java.lang.Long;
import java.lang.Object;
import java.lang.Override;
import java.lang.String;
import java.lang.SuppressWarnings;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.Callable;
import javax.annotation.processing.Generated;
import kotlin.Unit;
import kotlin.coroutines.Continuation;
import kotlinx.coroutines.flow.Flow;

@Generated("androidx.room.RoomProcessor")
@SuppressWarnings({"unchecked", "deprecation"})
public final class VitalDao_Impl implements VitalDao {
  private final RoomDatabase __db;

  private final EntityInsertionAdapter<VitalRecordEntity> __insertionAdapterOfVitalRecordEntity;

  private final EntityDeletionOrUpdateAdapter<VitalRecordEntity> __deletionAdapterOfVitalRecordEntity;

  private final SharedSQLiteStatement __preparedStmtOfClearAll;

  public VitalDao_Impl(@NonNull final RoomDatabase __db) {
    this.__db = __db;
    this.__insertionAdapterOfVitalRecordEntity = new EntityInsertionAdapter<VitalRecordEntity>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "INSERT OR REPLACE INTO `vital_records` (`id`,`timestamp`,`heartRate`,`hrvRmssd`,`hrvSdnn`,`respirationRate`,`stressIndex`,`skinVitality`,`skinAge`) VALUES (nullif(?, 0),?,?,?,?,?,?,?,?)";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final VitalRecordEntity entity) {
        statement.bindLong(1, entity.getId());
        statement.bindLong(2, entity.getTimestamp());
        statement.bindDouble(3, entity.getHeartRate());
        statement.bindDouble(4, entity.getHrvRmssd());
        statement.bindDouble(5, entity.getHrvSdnn());
        statement.bindDouble(6, entity.getRespirationRate());
        statement.bindDouble(7, entity.getStressIndex());
        statement.bindDouble(8, entity.getSkinVitality());
        statement.bindLong(9, entity.getSkinAge());
      }
    };
    this.__deletionAdapterOfVitalRecordEntity = new EntityDeletionOrUpdateAdapter<VitalRecordEntity>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "DELETE FROM `vital_records` WHERE `id` = ?";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final VitalRecordEntity entity) {
        statement.bindLong(1, entity.getId());
      }
    };
    this.__preparedStmtOfClearAll = new SharedSQLiteStatement(__db) {
      @Override
      @NonNull
      public String createQuery() {
        final String _query = "DELETE FROM vital_records";
        return _query;
      }
    };
  }

  @Override
  public Object insertRecord(final VitalRecordEntity record,
      final Continuation<? super Long> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Long>() {
      @Override
      @NonNull
      public Long call() throws Exception {
        __db.beginTransaction();
        try {
          final Long _result = __insertionAdapterOfVitalRecordEntity.insertAndReturnId(record);
          __db.setTransactionSuccessful();
          return _result;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object deleteRecord(final VitalRecordEntity record,
      final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __deletionAdapterOfVitalRecordEntity.handle(record);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object clearAll(final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        final SupportSQLiteStatement _stmt = __preparedStmtOfClearAll.acquire();
        try {
          __db.beginTransaction();
          try {
            _stmt.executeUpdateDelete();
            __db.setTransactionSuccessful();
            return Unit.INSTANCE;
          } finally {
            __db.endTransaction();
          }
        } finally {
          __preparedStmtOfClearAll.release(_stmt);
        }
      }
    }, $completion);
  }

  @Override
  public Flow<List<VitalRecordEntity>> getAllRecords() {
    final String _sql = "SELECT * FROM vital_records ORDER BY timestamp DESC";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 0);
    return CoroutinesRoom.createFlow(__db, false, new String[] {"vital_records"}, new Callable<List<VitalRecordEntity>>() {
      @Override
      @NonNull
      public List<VitalRecordEntity> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfTimestamp = CursorUtil.getColumnIndexOrThrow(_cursor, "timestamp");
          final int _cursorIndexOfHeartRate = CursorUtil.getColumnIndexOrThrow(_cursor, "heartRate");
          final int _cursorIndexOfHrvRmssd = CursorUtil.getColumnIndexOrThrow(_cursor, "hrvRmssd");
          final int _cursorIndexOfHrvSdnn = CursorUtil.getColumnIndexOrThrow(_cursor, "hrvSdnn");
          final int _cursorIndexOfRespirationRate = CursorUtil.getColumnIndexOrThrow(_cursor, "respirationRate");
          final int _cursorIndexOfStressIndex = CursorUtil.getColumnIndexOrThrow(_cursor, "stressIndex");
          final int _cursorIndexOfSkinVitality = CursorUtil.getColumnIndexOrThrow(_cursor, "skinVitality");
          final int _cursorIndexOfSkinAge = CursorUtil.getColumnIndexOrThrow(_cursor, "skinAge");
          final List<VitalRecordEntity> _result = new ArrayList<VitalRecordEntity>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final VitalRecordEntity _item;
            final long _tmpId;
            _tmpId = _cursor.getLong(_cursorIndexOfId);
            final long _tmpTimestamp;
            _tmpTimestamp = _cursor.getLong(_cursorIndexOfTimestamp);
            final double _tmpHeartRate;
            _tmpHeartRate = _cursor.getDouble(_cursorIndexOfHeartRate);
            final double _tmpHrvRmssd;
            _tmpHrvRmssd = _cursor.getDouble(_cursorIndexOfHrvRmssd);
            final double _tmpHrvSdnn;
            _tmpHrvSdnn = _cursor.getDouble(_cursorIndexOfHrvSdnn);
            final double _tmpRespirationRate;
            _tmpRespirationRate = _cursor.getDouble(_cursorIndexOfRespirationRate);
            final double _tmpStressIndex;
            _tmpStressIndex = _cursor.getDouble(_cursorIndexOfStressIndex);
            final double _tmpSkinVitality;
            _tmpSkinVitality = _cursor.getDouble(_cursorIndexOfSkinVitality);
            final int _tmpSkinAge;
            _tmpSkinAge = _cursor.getInt(_cursorIndexOfSkinAge);
            _item = new VitalRecordEntity(_tmpId,_tmpTimestamp,_tmpHeartRate,_tmpHrvRmssd,_tmpHrvSdnn,_tmpRespirationRate,_tmpStressIndex,_tmpSkinVitality,_tmpSkinAge);
            _result.add(_item);
          }
          return _result;
        } finally {
          _cursor.close();
        }
      }

      @Override
      protected void finalize() {
        _statement.release();
      }
    });
  }

  @NonNull
  public static List<Class<?>> getRequiredConverters() {
    return Collections.emptyList();
  }
}
