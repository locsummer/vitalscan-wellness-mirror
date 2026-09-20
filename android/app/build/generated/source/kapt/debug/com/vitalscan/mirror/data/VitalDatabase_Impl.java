package com.vitalscan.mirror.data;

import androidx.annotation.NonNull;
import androidx.room.DatabaseConfiguration;
import androidx.room.InvalidationTracker;
import androidx.room.RoomDatabase;
import androidx.room.RoomOpenHelper;
import androidx.room.migration.AutoMigrationSpec;
import androidx.room.migration.Migration;
import androidx.room.util.DBUtil;
import androidx.room.util.TableInfo;
import androidx.sqlite.db.SupportSQLiteDatabase;
import androidx.sqlite.db.SupportSQLiteOpenHelper;
import java.lang.Class;
import java.lang.Override;
import java.lang.String;
import java.lang.SuppressWarnings;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import javax.annotation.processing.Generated;

@Generated("androidx.room.RoomProcessor")
@SuppressWarnings({"unchecked", "deprecation"})
public final class VitalDatabase_Impl extends VitalDatabase {
  private volatile VitalDao _vitalDao;

  @Override
  @NonNull
  protected SupportSQLiteOpenHelper createOpenHelper(@NonNull final DatabaseConfiguration config) {
    final SupportSQLiteOpenHelper.Callback _openCallback = new RoomOpenHelper(config, new RoomOpenHelper.Delegate(1) {
      @Override
      public void createAllTables(@NonNull final SupportSQLiteDatabase db) {
        db.execSQL("CREATE TABLE IF NOT EXISTS `vital_records` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `timestamp` INTEGER NOT NULL, `heartRate` REAL NOT NULL, `hrvRmssd` REAL NOT NULL, `hrvSdnn` REAL NOT NULL, `respirationRate` REAL NOT NULL, `stressIndex` REAL NOT NULL, `skinVitality` REAL NOT NULL, `skinAge` INTEGER NOT NULL)");
        db.execSQL("CREATE TABLE IF NOT EXISTS room_master_table (id INTEGER PRIMARY KEY,identity_hash TEXT)");
        db.execSQL("INSERT OR REPLACE INTO room_master_table (id,identity_hash) VALUES(42, 'f07d119e6b05c364237615679092b35e')");
      }

      @Override
      public void dropAllTables(@NonNull final SupportSQLiteDatabase db) {
        db.execSQL("DROP TABLE IF EXISTS `vital_records`");
        final List<? extends RoomDatabase.Callback> _callbacks = mCallbacks;
        if (_callbacks != null) {
          for (RoomDatabase.Callback _callback : _callbacks) {
            _callback.onDestructiveMigration(db);
          }
        }
      }

      @Override
      public void onCreate(@NonNull final SupportSQLiteDatabase db) {
        final List<? extends RoomDatabase.Callback> _callbacks = mCallbacks;
        if (_callbacks != null) {
          for (RoomDatabase.Callback _callback : _callbacks) {
            _callback.onCreate(db);
          }
        }
      }

      @Override
      public void onOpen(@NonNull final SupportSQLiteDatabase db) {
        mDatabase = db;
        internalInitInvalidationTracker(db);
        final List<? extends RoomDatabase.Callback> _callbacks = mCallbacks;
        if (_callbacks != null) {
          for (RoomDatabase.Callback _callback : _callbacks) {
            _callback.onOpen(db);
          }
        }
      }

      @Override
      public void onPreMigrate(@NonNull final SupportSQLiteDatabase db) {
        DBUtil.dropFtsSyncTriggers(db);
      }

      @Override
      public void onPostMigrate(@NonNull final SupportSQLiteDatabase db) {
      }

      @Override
      @NonNull
      public RoomOpenHelper.ValidationResult onValidateSchema(
          @NonNull final SupportSQLiteDatabase db) {
        final HashMap<String, TableInfo.Column> _columnsVitalRecords = new HashMap<String, TableInfo.Column>(9);
        _columnsVitalRecords.put("id", new TableInfo.Column("id", "INTEGER", true, 1, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsVitalRecords.put("timestamp", new TableInfo.Column("timestamp", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsVitalRecords.put("heartRate", new TableInfo.Column("heartRate", "REAL", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsVitalRecords.put("hrvRmssd", new TableInfo.Column("hrvRmssd", "REAL", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsVitalRecords.put("hrvSdnn", new TableInfo.Column("hrvSdnn", "REAL", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsVitalRecords.put("respirationRate", new TableInfo.Column("respirationRate", "REAL", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsVitalRecords.put("stressIndex", new TableInfo.Column("stressIndex", "REAL", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsVitalRecords.put("skinVitality", new TableInfo.Column("skinVitality", "REAL", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsVitalRecords.put("skinAge", new TableInfo.Column("skinAge", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        final HashSet<TableInfo.ForeignKey> _foreignKeysVitalRecords = new HashSet<TableInfo.ForeignKey>(0);
        final HashSet<TableInfo.Index> _indicesVitalRecords = new HashSet<TableInfo.Index>(0);
        final TableInfo _infoVitalRecords = new TableInfo("vital_records", _columnsVitalRecords, _foreignKeysVitalRecords, _indicesVitalRecords);
        final TableInfo _existingVitalRecords = TableInfo.read(db, "vital_records");
        if (!_infoVitalRecords.equals(_existingVitalRecords)) {
          return new RoomOpenHelper.ValidationResult(false, "vital_records(com.vitalscan.mirror.data.VitalRecordEntity).\n"
                  + " Expected:\n" + _infoVitalRecords + "\n"
                  + " Found:\n" + _existingVitalRecords);
        }
        return new RoomOpenHelper.ValidationResult(true, null);
      }
    }, "f07d119e6b05c364237615679092b35e", "f6838255f45bc07b1182fb3b8e17a6dd");
    final SupportSQLiteOpenHelper.Configuration _sqliteConfig = SupportSQLiteOpenHelper.Configuration.builder(config.context).name(config.name).callback(_openCallback).build();
    final SupportSQLiteOpenHelper _helper = config.sqliteOpenHelperFactory.create(_sqliteConfig);
    return _helper;
  }

  @Override
  @NonNull
  protected InvalidationTracker createInvalidationTracker() {
    final HashMap<String, String> _shadowTablesMap = new HashMap<String, String>(0);
    final HashMap<String, Set<String>> _viewTables = new HashMap<String, Set<String>>(0);
    return new InvalidationTracker(this, _shadowTablesMap, _viewTables, "vital_records");
  }

  @Override
  public void clearAllTables() {
    super.assertNotMainThread();
    final SupportSQLiteDatabase _db = super.getOpenHelper().getWritableDatabase();
    try {
      super.beginTransaction();
      _db.execSQL("DELETE FROM `vital_records`");
      super.setTransactionSuccessful();
    } finally {
      super.endTransaction();
      _db.query("PRAGMA wal_checkpoint(FULL)").close();
      if (!_db.inTransaction()) {
        _db.execSQL("VACUUM");
      }
    }
  }

  @Override
  @NonNull
  protected Map<Class<?>, List<Class<?>>> getRequiredTypeConverters() {
    final HashMap<Class<?>, List<Class<?>>> _typeConvertersMap = new HashMap<Class<?>, List<Class<?>>>();
    _typeConvertersMap.put(VitalDao.class, VitalDao_Impl.getRequiredConverters());
    return _typeConvertersMap;
  }

  @Override
  @NonNull
  public Set<Class<? extends AutoMigrationSpec>> getRequiredAutoMigrationSpecs() {
    final HashSet<Class<? extends AutoMigrationSpec>> _autoMigrationSpecsSet = new HashSet<Class<? extends AutoMigrationSpec>>();
    return _autoMigrationSpecsSet;
  }

  @Override
  @NonNull
  public List<Migration> getAutoMigrations(
      @NonNull final Map<Class<? extends AutoMigrationSpec>, AutoMigrationSpec> autoMigrationSpecs) {
    final List<Migration> _autoMigrations = new ArrayList<Migration>();
    return _autoMigrations;
  }

  @Override
  public VitalDao vitalDao() {
    if (_vitalDao != null) {
      return _vitalDao;
    } else {
      synchronized(this) {
        if(_vitalDao == null) {
          _vitalDao = new VitalDao_Impl(this);
        }
        return _vitalDao;
      }
    }
  }
}
