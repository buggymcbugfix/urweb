#include "include/urweb/config.h"
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
 #include <math.h>
 #include <time.h>
 #include "tests/run/io_rpc/iocheck.h"
  #include "include/urweb/urweb.h"
 
 static void uw_setup_limits() {
  uw_min_heap = 65536;
   
   }
  
  void uw_global_custom() {
   uw_setup_limits();
   }
   static void uw_client_init(void) { };
    static void uw_db_init(uw_context ctx) { };
    static int uw_db_begin(uw_context ctx, int could_write) { return 0; };
    static void uw_db_close(uw_context ctx) { };
    static int uw_db_commit(uw_context ctx) { return 0; };
    static int uw_db_rollback(uw_context ctx) { return 0; };
 
 /* No global setup for LRU cache. */
  
 
  
  struct __uws_1 {
   uw_Basis_channel __uwf_Ch;
    };
  struct __uws_2 {
   struct __uws_1 __uwf_Chans;
    };
  struct __uws_3 {
   uw_Basis_int __uwf_N;
    };
  struct __uws_4 {
   struct __uws_3 __uwf_T;
    };
  
  static char jslib[] = "*runtime elided*";
   static char jsapp[] = "*script elided*";
  /* SQL table uw_Io_rpc_t constraints   */
   
  /* SQL table uw_Io_rpc_chans constraints   */
   
  
  static uw_Basis_int
   __uwn_twice_1(uw_context ctx, uw_Basis_int __uwr_n_0, uw_unit __uwr___1)
   {
   return(({
           uw_unit __uwr___2 =
           (uw_begin_region(ctx), uw_Basis_debug(ctx,
                                   ({
                                    uw_Basis_string arg0 = "call ";
                                     
                                     uw_Basis_string arg1 =
                                      uw_Basis_intToString(ctx,
                                       uw_Iocheck_step(ctx));
                                      uw_Basis_string arg2 = ": twice ";
                                       
                                     uw_Basis_string arg3 =
                                      uw_Basis_intToString(ctx, __uwr_n_0);
                                      uw_Basis_mstrcat(ctx, arg0, arg1, arg2, 
                                                             arg3, NULL);
                                    })));
           uw_end_region(ctx);
            ({
             uw_unit __uwr___3 =
             (uw_begin_region(ctx), uw_Basis_debug(ctx,
                                     ({
                                      uw_Basis_string arg0 =
                                       "transaction open around the body: ";
                                       
                                       uw_Basis_string arg1 =
                                        uw_Basis_boolToString(ctx,
                                         uw_Iocheck_inTransaction(ctx));
                                        uw_Basis_strcat(ctx, arg0, arg1);
                                      })));
             uw_end_region(ctx);
              ({
               uw_unit __uwr___4 =
               (uw_begin_region(ctx), uw_Basis_debug(ctx,
                                       ({
                                        uw_Basis_string arg0 =
                                         "transaction open inside runTransaction: ";
                                         
                                         uw_Basis_string arg1 =
                                          uw_Basis_boolToString(ctx,
                                           ({
                                            uw_io_transaction __uwt;
                                            uw_Basis_bool
                                            __uwr;
                                            uw_io_transaction_begin(ctx, &__uwt);
                                            while (1) {
                                            int __uwfk = setjmp(*uw_jmp_buf(ctx));
                                             if (__uwfk == 0) {
                                             __uwr =
                                              ({
                                               uw_unit __uwr___4 =
                                               (uw_begin_region(ctx), (uw_begin_region(ctx), ({
                                                                       uw_Basis_int
                                                                        arg1 =
                                                                        __uwr_n_0;
                                                                        
                                                                        uw_ensure_transaction(ctx);
                                                                        
                                                                        PGconn *conn = uw_get_db(ctx);
                                                                         static const int paramFormats[] = { 0 };
                                                                          const int *paramLengths = paramFormats;
                                                                           const char **paramValues = uw_malloc(ctx, 1 * sizeof(char*));
                                                                          paramValues[0] = 
                                                                           uw_Basis_attrifyInt(ctx, 
                                                                            arg1);
                                                                           
                                                                          
                                                                         PGresult *res;
                                                                         
                                                                         res = PQexecPrepared(conn, "uw0", 1, paramValues, paramLengths, paramFormats, 0);
                                                                         
                                                                         if (res == NULL) {
                                                                          
                                                                           uw_try_reconnecting_and_restarting(ctx);
                                                                           uw_error(ctx, FATAL, "Can't allocate DML result; database server may be down.");
                                                                           }
                                                                          
                                                                          if (PQresultStatus(res) != PGRES_COMMAND_OK) {
                                                                          if (!strcmp_nullsafe(PQresultErrorField(res, PG_DIAG_SQLSTATE), "40001")) {
                                                                           
                                                                            PQclear(res);
                                                                            uw_error(ctx, UNLIMITED_RETRY, "Serialization failure");
                                                                            }
                                                                           if (!strcmp_nullsafe(PQresultErrorField(res, PG_DIAG_SQLSTATE), "40P01")) {
                                                                           
                                                                            PQclear(res);
                                                                            uw_error(ctx, UNLIMITED_RETRY, "Deadlock detected");
                                                                            }
                                                                           PQclear(res);
                                                                            uw_error(ctx, FATAL, "tests/run/io_rpc/io_rpc.ur:18:30-19:52: DML failed:\n%s\n%s", 
                                                                            "INSERT INTO uw_Io_rpc_t (uw_N) VALUES ($1::int8)", PQerrorMessage(conn));
                                                                           }
                                                                             
                                                                             PQclear(res);
                                                                             
                                                                       
                                                                       uw_end_region(ctx);
                                                                       0;
                                                                       })));
                                               uw_end_region(ctx);
                                                uw_Iocheck_inTransactionT(ctx);
                                               });
                                              uw_io_transaction_commit(ctx, &__uwt);
                                              break;
                                              } else if (!uw_io_transaction_retry(ctx, &__uwt, __uwfk)) {
                                             break;
                                              }
                                             }
                                            uw_io_transaction_end(ctx, &__uwt, 1);
                                            __uwr;
                                            }));
                                          uw_Basis_strcat(ctx, arg0, arg1);
                                        })));
               uw_end_region(ctx);
                ({
                 uw_unit __uwr___5 =
                 (uw_begin_region(ctx), uw_Iocheck_effect(ctx,
                                         "between transactions"));
                 uw_end_region(ctx);
                  ({
                   uw_unit __uwr___6 =
                   (uw_begin_region(ctx), ({
                                           uw_io_transaction __uwt;
                                           uw_unit
                                           __uwr;
                                           uw_io_transaction_begin(ctx, &__uwt);
                                           while (1) {
                                           int __uwfk = setjmp(*uw_jmp_buf(ctx));
                                            if (__uwfk == 0) {
                                            __uwr =
                                             ({
                                              uw_Basis_client __uwr___6 =
                                              (uw_begin_region(ctx), uw_Basis_self(ctx
                                                                      ));
                                              uw_end_region(ctx);
                                               (uw_begin_region(ctx), ({
                                                uw_unit acc =
                                                0;
                                                int dummy = (uw_begin_region(ctx), 0);
                                                uw_ensure_transaction(ctx);
                                                
                                                 
                                                 PGconn *conn = uw_get_db(ctx);
                                                  static const int paramFormats[] = {  };
                                                   const int *paramLengths = paramFormats;
                                                    const char **paramValues = uw_malloc(ctx, 0 * sizeof(char*));
                                                   
                                                   
                                                  PGresult *res = PQexecPrepared(conn, "uw1", 0, paramValues, paramLengths, paramFormats, 0);
                                                  
                                                  int n, i;
                                                   
                                                   if (res == NULL) {
                                                                      uw_try_reconnecting_and_restarting(ctx);
                                                                      uw_error(ctx, FATAL, "Can't allocate query result; database server may be down.");
                                                                      }
                                                   
                                                   if (PQresultStatus(res) != PGRES_TUPLES_OK) {
                                                   if (!strcmp_nullsafe(PQresultErrorField(res, PG_DIAG_SQLSTATE), "40001")) {
                                                    
                                                     PQclear(res);
                                                     uw_error(ctx, UNLIMITED_RETRY, "Serialization failure");
                                                     }
                                                    if (!strcmp_nullsafe(PQresultErrorField(res, PG_DIAG_SQLSTATE), "40P01")) {
                                                    
                                                     PQclear(res);
                                                     uw_error(ctx, UNLIMITED_RETRY, "Deadlock detected");
                                                     }
                                                    PQclear(res);
                                                    uw_error(ctx, FATAL, "tests/run/io_rpc/io_rpc.ur:22:20-24:87: Query failed:\n%s\n%s", 
                                                    "SELECT T_Chans.uw_Ch FROM uw_Io_rpc_chans AS T_Chans", PQerrorMessage(conn));
                                                    }
                                                   
                                                   if (PQnfields(res) != 1) {
                                                   int nf = PQnfields(res);
                                                    PQclear(res);
                                                    uw_error(ctx, FATAL, "tests/run/io_rpc/io_rpc.ur:22:20-24:87: Query returned %d columns instead of 1:\n%s\n%s", nf, 
                                                    "SELECT T_Chans.uw_Ch FROM uw_Io_rpc_chans AS T_Chans", PQerrorMessage(conn));
                                                    }
                                                   
                                                   uw_end_region(ctx);
                                                   uw_push_cleanup(ctx, (void (*)(void *))PQclear, res);
                                                   n = PQntuples(res);
                                                   for (i = 0; i < n; ++i) {
                                                   struct __uws_2 __uwr_r_7;
                                                    uw_unit __uwr_acc_8 =
                                                    acc;
                                                    
                                                    __uwr_r_7.__uwf_Chans.__uwf_Ch
                                                     =
                                                     (PQgetisnull(res, i, 0) ? ({uw_Basis_channel
                                                                               tmp;
                                                                               uw_error(ctx, FATAL, "tests/run/io_rpc/io_rpc.ur:22:20-24:87: Unexpectedly NULL field #0");
                                                                               tmp;
                                                                               }) : 
                                                      uw_Basis_stringToChannel_error(ctx, 
                                                       PQgetvalue(res, i, 0)));
                                                     
                                                    
                                                    acc =
                                                    ({
                                                     uw_Basis_channel arg0 =
                                                      __uwr_r_7.__uwf_Chans.__uwf_Ch;
                                                      
                                                      uw_Basis_string arg1 =
                                                       "sent+from+the+second+transaction";
                                                       uw_Basis_send(ctx, arg0, 
                                                                           arg1);
                                                     });
                                                    }
                                                   
                                                   uw_pop_cleanup(ctx);
                                                   
                                                uw_end_region(ctx);
                                                 acc;
                                                }));
                                              });
                                             uw_io_transaction_commit(ctx, &__uwt);
                                             break;
                                             } else if (!uw_io_transaction_retry(ctx, &__uwt, __uwfk)) {
                                            break;
                                             }
                                            }
                                           uw_io_transaction_end(ctx, &__uwt, 1);
                                           __uwr;
                                           }));
                   uw_end_region(ctx);
                    __uwr_n_0 * 2LL;
                   });
                 });
               });
             });
           }));
   }
  
  static uw_Basis_int
   __uwn_boom_2(uw_context ctx, uw_Basis_int __uwr_n_0, uw_unit __uwr___1)
   {
   return(({
           uw_unit __uwr___2 =
           (uw_begin_region(ctx), uw_Basis_debug(ctx,
                                   ({
                                    uw_Basis_string arg0 = "call ";
                                     
                                     uw_Basis_string arg1 =
                                      uw_Basis_intToString(ctx,
                                       uw_Iocheck_step(ctx));
                                      uw_Basis_string arg2 = ": boom ";
                                       
                                     uw_Basis_string arg3 =
                                      uw_Basis_intToString(ctx, __uwr_n_0);
                                      uw_Basis_mstrcat(ctx, arg0, arg1, arg2, 
                                                             arg3, NULL);
                                    })));
           uw_end_region(ctx);
            ({
             uw_unit __uwr___3 =
             (uw_begin_region(ctx), ({
                                     uw_io_transaction __uwt;
                                     uw_unit
                                     __uwr;
                                     uw_io_transaction_begin(ctx, &__uwt);
                                     while (1) {
                                     int __uwfk = setjmp(*uw_jmp_buf(ctx));
                                      if (__uwfk == 0) {
                                      __uwr =
                                       (uw_begin_region(ctx), ({
                                        uw_Basis_int arg1 = __uwr_n_0;
                                         
                                         uw_ensure_transaction(ctx);
                                         
                                         PGconn *conn = uw_get_db(ctx);
                                          static const int paramFormats[] = { 0 };
                                           const int *paramLengths = paramFormats;
                                            const char **paramValues = uw_malloc(ctx, 1 * sizeof(char*));
                                           paramValues[0] = uw_Basis_attrifyInt(ctx, 
                                                             arg1);
                                            
                                           
                                          PGresult *res;
                                          
                                          res = PQexecPrepared(conn, "uw0", 1, paramValues, paramLengths, paramFormats, 0);
                                          
                                          if (res == NULL) {
                                                             uw_try_reconnecting_and_restarting(ctx);
                                                             uw_error(ctx, FATAL, "Can't allocate DML result; database server may be down.");
                                                             }
                                           
                                           if (PQresultStatus(res) != PGRES_COMMAND_OK) {
                                           if (!strcmp_nullsafe(PQresultErrorField(res, PG_DIAG_SQLSTATE), "40001")) {
                                            
                                             PQclear(res);
                                             uw_error(ctx, UNLIMITED_RETRY, "Serialization failure");
                                             }
                                            if (!strcmp_nullsafe(PQresultErrorField(res, PG_DIAG_SQLSTATE), "40P01")) {
                                            
                                             PQclear(res);
                                             uw_error(ctx, UNLIMITED_RETRY, "Deadlock detected");
                                             }
                                            PQclear(res);
                                             uw_error(ctx, FATAL, "tests/run/io_rpc/io_rpc.ur:32:4-32:59: DML failed:\n%s\n%s", 
                                             "INSERT INTO uw_Io_rpc_t (uw_N) VALUES ($1::int8)", PQerrorMessage(conn));
                                            }
                                              
                                              PQclear(res);
                                              
                                        
                                        uw_end_region(ctx);
                                        0;
                                        }));
                                       uw_io_transaction_commit(ctx, &__uwt);
                                       break;
                                       } else if (!uw_io_transaction_retry(ctx, &__uwt, __uwfk)) {
                                      break;
                                       }
                                      }
                                     uw_io_transaction_end(ctx, &__uwt, 1);
                                     __uwr;
                                     }));
             uw_end_region(ctx);
              ({
               uw_io_transaction __uwt;
               uw_Basis_int
               __uwr;
               uw_io_transaction_begin(ctx, &__uwt);
               while (1) {
               int __uwfk = setjmp(*uw_jmp_buf(ctx));
                if (__uwfk == 0) {
                __uwr =
                 ({
                  uw_Basis_int
                  tmp;
                  uw_error(ctx, FATAL, "tests/run/io_rpc/io_rpc.ur:33:19-33:68: %s", 
                  "boom in the second transaction");
                  tmp;
                  });
                 uw_io_transaction_commit(ctx, &__uwt);
                 break;
                 } else if (!uw_io_transaction_retry(ctx, &__uwt, __uwfk)) {
                break;
                 }
                }
               uw_io_transaction_end(ctx, &__uwt, 1);
               __uwr;
               });
             });
           }));
   }
  
  static uw_Basis_int
   __uwn_flaky_3(uw_context ctx, uw_Basis_int __uwr_n_0, uw_unit __uwr___1)
   {
   return(({
           uw_unit __uwr___2 =
           (uw_begin_region(ctx), uw_Basis_debug(ctx,
                                   ({
                                    uw_Basis_string arg0 = "call ";
                                     
                                     uw_Basis_string arg1 =
                                      uw_Basis_intToString(ctx,
                                       uw_Iocheck_step(ctx));
                                      uw_Basis_string arg2 = ": flaky ";
                                       
                                     uw_Basis_string arg3 =
                                      uw_Basis_intToString(ctx, __uwr_n_0);
                                      uw_Basis_mstrcat(ctx, arg0, arg1, arg2, 
                                                             arg3, NULL);
                                    })));
           uw_end_region(ctx);
            ({
             uw_unit __uwr___3 =
             (uw_begin_region(ctx), uw_Iocheck_boundedRetryIo(ctx,
                                     "flaky, outside any transaction"));
             uw_end_region(ctx);
              __uwr_n_0;
             });
           }));
   }
  
  static uw_unit
   __uwn_wrap_rows_4(uw_context ctx, uw_unit __uwr_x0_0, uw_unit __uwr___1)
   {
   return(((uw_write(ctx, "<body"), 0),
           (uw_begin_region(ctx), (uw_write(ctx, uw_Basis_maybe_onload(ctx,
                                                  uw_Basis_get_settings(ctx, 0))), 0),
            uw_end_region(ctx), (uw_begin_region(ctx), (uw_write(ctx, uw_Basis_maybe_onunload(ctx,
                                                                       "")), 0),
                                 uw_end_region(ctx), ((uw_write(ctx, ">"), 0),
                                                      (uw_begin_region(ctx), (uw_begin_region(ctx), ({
                                                                              uw_unit
                                                                              acc
                                                                              =
                                                                              0;
                                                                              int dummy = (uw_begin_region(ctx), 0);
                                                                              uw_ensure_transaction(ctx);
                                                                              
                                                                               
                                                                               PGconn *conn = uw_get_db(ctx);
                                                                               static const int paramFormats[] = {  };
                                                                               const int *paramLengths = paramFormats;
                                                                               const char **paramValues = uw_malloc(ctx, 0 * sizeof(char*));
                                                                               
                                                                               
                                                                               PGresult *res = 
                                                                               PQexecPrepared(conn, "uw2", 0, paramValues, paramLengths, paramFormats, 0);
                                                                               
                                                                               int n, i;
                                                                               
                                                                               if (res == NULL) {
                                                                               
                                                                               uw_try_reconnecting_and_restarting(ctx);
                                                                               uw_error(ctx, FATAL, "Can't allocate query result; database server may be down.");
                                                                               }
                                                                               
                                                                               if (PQresultStatus(res) != PGRES_TUPLES_OK) {
                                                                               if (!strcmp_nullsafe(PQresultErrorField(res, PG_DIAG_SQLSTATE), "40001")) {
                                                                               
                                                                               PQclear(res);
                                                                               uw_error(ctx, UNLIMITED_RETRY, "Serialization failure");
                                                                               }
                                                                               if (!strcmp_nullsafe(PQresultErrorField(res, PG_DIAG_SQLSTATE), "40P01")) {
                                                                               
                                                                               PQclear(res);
                                                                               uw_error(ctx, UNLIMITED_RETRY, "Deadlock detected");
                                                                               }
                                                                               PQclear(res);
                                                                               uw_error(ctx, FATAL, "tests/run/io_rpc/io_rpc.ur:45:20-45:26: Query failed:\n%s\n%s", 
                                                                               "SELECT T_T.uw_N FROM uw_Io_rpc_t AS T_T ORDER BY T_T.uw_N", PQerrorMessage(conn));
                                                                               }
                                                                               
                                                                               if (PQnfields(res) != 1) {
                                                                               int nf = PQnfields(res);
                                                                               PQclear(res);
                                                                               uw_error(ctx, FATAL, "tests/run/io_rpc/io_rpc.ur:45:20-45:26: Query returned %d columns instead of 1:\n%s\n%s", nf, 
                                                                               "SELECT T_T.uw_N FROM uw_Io_rpc_t AS T_T ORDER BY T_T.uw_N", PQerrorMessage(conn));
                                                                               }
                                                                               
                                                                               uw_end_region(ctx);
                                                                               uw_push_cleanup(ctx, (void (*)(void *))PQclear, res);
                                                                               n = PQntuples(res);
                                                                               for (i = 0; i < n; ++i) {
                                                                               struct __uws_4 __uwr_r_2;
                                                                               uw_unit
                                                                               __uwr_acc_3
                                                                               =
                                                                               acc;
                                                                               
                                                                               __uwr_r_2.__uwf_T.__uwf_N
                                                                               =
                                                                               (PQgetisnull(res, i, 0) ? 
                                                                               ({uw_Basis_int
                                                                               tmp;
                                                                               uw_error(ctx, FATAL, "tests/run/io_rpc/io_rpc.ur:45:20-45:26: Unexpectedly NULL field #0");
                                                                               tmp;
                                                                               }) : 
                                                                               uw_Basis_stringToInt_error(ctx, 
                                                                               PQgetvalue(res, i, 0)));
                                                                               
                                                                               
                                                                               acc
                                                                               =
                                                                               (uw_begin_region(ctx),
                                                                               uw_Basis_htmlifyInt_w(ctx,
                                                                               __uwr_r_2.__uwf_T.__uwf_N
                                                                               ),
                                                                               uw_end_region(ctx),
                                                                               (uw_write(ctx, 
                                                                               " "), 0));
                                                                               }
                                                                               
                                                                               uw_pop_cleanup(ctx);
                                                                               
                                                                              uw_end_region(ctx);
                                                                               acc;
                                                                              })),
                                                       uw_end_region(ctx), (uw_write(ctx, 
                                                                            "</body>"), 0)))))));
   }
  
  static uw_unit
   __uwn_wrap_main_5(uw_context ctx, uw_unit __uwr_x0_0, uw_unit __uwr___1)
   {
   return(({
           uw_Basis_channel __uwr_ch_2 =
           (uw_begin_region(ctx), uw_Basis_new_channel(ctx, 0));
           uw_end_region(ctx);
            ({
             uw_unit __uwr___3 =
             (uw_begin_region(ctx), (uw_begin_region(ctx), ({
                                     uw_Basis_channel arg1 = __uwr_ch_2;
                                      
                                      uw_ensure_transaction(ctx);
                                      
                                      PGconn *conn = uw_get_db(ctx);
                                       static const int paramFormats[] = { 0 };
                                        const int *paramLengths = paramFormats;
                                         const char **paramValues = uw_malloc(ctx, 1 * sizeof(char*));
                                        paramValues[0] = uw_Basis_attrifyChannel(ctx, 
                                                          arg1);
                                         
                                        
                                       PGresult *res;
                                       
                                       res = PQexecPrepared(conn, "uw3", 1, paramValues, paramLengths, paramFormats, 0);
                                       
                                       if (res == NULL) {
                                                          uw_try_reconnecting_and_restarting(ctx);
                                                          uw_error(ctx, FATAL, "Can't allocate DML result; database server may be down.");
                                                          }
                                        
                                        if (PQresultStatus(res) != PGRES_COMMAND_OK) {
                                        if (!strcmp_nullsafe(PQresultErrorField(res, PG_DIAG_SQLSTATE), "40001")) {
                                         
                                          PQclear(res);
                                          uw_error(ctx, UNLIMITED_RETRY, "Serialization failure");
                                          }
                                         if (!strcmp_nullsafe(PQresultErrorField(res, PG_DIAG_SQLSTATE), "40P01")) {
                                         
                                          PQclear(res);
                                          uw_error(ctx, UNLIMITED_RETRY, "Deadlock detected");
                                          }
                                         PQclear(res);
                                          uw_error(ctx, FATAL, "tests/run/io_rpc/io_rpc.ur:49:4-60:3: DML failed:\n%s\n%s", 
                                          "INSERT INTO uw_Io_rpc_chans (uw_Ch) VALUES ($1::int8)", PQerrorMessage(conn));
                                         }
                                           
                                           PQclear(res);
                                           
                                     
                                     uw_end_region(ctx);
                                     0;
                                     })));
             uw_end_region(ctx);
              ({
               uw_Basis_source __uwr_s_4 =
               uw_Basis_new_client_source(ctx,
                ({
                 uw_Basis_string arg0 = "{c:\"c\",v:";
                  uw_Basis_string arg1 = uw_Basis_htmlifyInt(ctx, 0LL);
                   uw_Basis_string arg2 = "}";
                    uw_Basis_mstrcat(ctx, arg0, arg1, arg2, NULL);
                 }));
               ((uw_write(ctx, "<body"), 0),
                (uw_begin_region(ctx), (uw_write(ctx, uw_Basis_maybe_onload(ctx,
                                                       ({
                                                        uw_Basis_string arg0 =
                                                         uw_Basis_get_settings(ctx,
                                                          0);
                                                         
                                                         uw_Basis_string arg1 =
                                                          "exec({c:\"a\",f:{c:\"a\",f:{c:\"n\",n:1},x:{c:\"c\",v:";
                                                          
                                                         uw_Basis_string arg2 =
                                                          uw_Basis_jsifyChannel(ctx,
                                                           __uwr_ch_2);
                                                          
                                                         uw_Basis_string arg3 =
                                                          "}},x:{c:\"c\",v:null}})";
                                                          uw_Basis_mstrcat(ctx, 
                                                        arg0, arg1, arg2, arg3,
                                                                               NULL);
                                                        }))), 0),
                 uw_end_region(ctx), (uw_begin_region(ctx), (uw_write(ctx, uw_Basis_maybe_onunload(ctx,
                                                                            "")), 0),
                                      uw_end_region(ctx), ((uw_write(ctx, ">\n<button onclick='uw_event=event;exec("), 0),
                                                           (uw_begin_region(ctx),
                                                             ((uw_write(ctx, "{c:\"a\",f:{c:\"a\",f:{c:\"n\",n:2},x:{c:\"c\",v:"), 0),
                                                              (uw_begin_region(ctx),
                                                                uw_Basis_htmlifySource_w(ctx,
                                                                 __uwr_s_4),
                                                               uw_end_region(ctx),
                                                                (uw_write(ctx, "}},x:{c:\"c\",v:null}}"), 0))),
                                                            uw_end_region(ctx), 
                                                            ((uw_write(ctx, ")'>twice</button>\n<button onclick='uw_event=event;exec("), 0),
                                                             (uw_begin_region(ctx),
                                                               ((uw_write(ctx, "{c:\"a\",f:{c:\"a\",f:{c:\"n\",n:3},x:{c:\"c\",v:"), 0),
                                                                (uw_begin_region(ctx),
                                                                  uw_Basis_htmlifySource_w(ctx,
                                                                   __uwr_s_4),
                                                                 uw_end_region(ctx),
                                                                  (uw_write(ctx, 
                                                                   "}},x:{c:\"c\",v:null}}"), 0))),
                                                              uw_end_region(ctx),
                                                               ((uw_write(ctx, ")'>boom</button>\n<button onclick='uw_event=event;exec("), 0),
                                                                (uw_begin_region(ctx),
                                                                  ((uw_write(ctx, 
                                                                    "{c:\"a\",f:{c:\"a\",f:{c:\"n\",n:4},x:{c:\"c\",v:"), 0),
                                                                   (uw_begin_region(ctx),
                                                                     uw_Basis_htmlifySource_w(ctx,
                                                                      __uwr_s_4),
                                                                    uw_end_region(ctx),
                                                                     (uw_write(ctx, 
                                                                      "}},x:{c:\"c\",v:null}}"), 0))),
                                                                 uw_end_region(ctx),
                                                                  ((uw_write(ctx, 
                                                                    ")'>flaky</button>\n<script type=\"text/javascript\">dyn(\"span\", execD("), 0),
                                                                   (uw_begin_region(ctx),
                                                                     ((uw_write(ctx, 
                                                                       "{c:\"a\",f:{c:\"a\",f:{c:\"n\",n:5},x:{c:\"c\",v:"), 0),
                                                                      (uw_begin_region(ctx),
                                                                        uw_Basis_htmlifySource_w(ctx,
                                                                         __uwr_s_4
                                                                         ),
                                                                       uw_end_region(ctx),
                                                                        (uw_write(ctx, 
                                                                         "}},x:{c:\"c\",v:null}}"), 0))),
                                                                    uw_end_region(ctx),
                                                                     (uw_write(ctx, 
                                                                      "))</script>\n</body>"), 0))))))))))));
               });
             });
           }));
   }
 
 static int uw_input_num(const char *name) {
 return -1;}
 
 static uw_periodic my_periodics[] = {{NULL}};
 
 static int uw_check_url(const char *s) {
  if (!strncmp(s, "#", 1)) return 1;
   if (!strcmp(s, "/Io_rpc/main")) return 1;
    if (!strcmp(s, "/Io_rpc/rows")) return 1;
     return 0;
   }
  
 static int uw_check_mime(const char *s) {
  return 0;
   }
  
 static int uw_check_requestHeader(const char *s) {
  return 0;
   }
  
 static int uw_check_responseHeader(const char *s) {
  return 0;
   }
  
 static int uw_check_envVar(const char *s) {
  return 0;
   }
  
 static int uw_check_meta(const char *s) {
  return 0;
   }
  
 extern void uw_sign(const char *in, char *out);
 extern int uw_hash_blocksize;
 static uw_Basis_string uw_cookie_sig(uw_context ctx) {
 uw_Basis_string r = uw_malloc(ctx, uw_hash_blocksize);
  uw_sign("", r);
  return uw_Basis_makeSigString(ctx, r);
  }
 
 static uw_served_file uw_served_files[] = {
 {NULL, NULL, 0, NULL}};
 
 static void uw_handle(uw_context ctx, char *request) {
 uw_Basis_string ims = uw_Basis_requestHeader(ctx, "If-modified-since");
 if (ims && !strcmp(ims, "Thu, 01 Jan 1970 00:00:00 GMT")) {
 uw_clear_headers(ctx);
  uw_write_header(ctx, uw_supports_direct_status ? "HTTP/1.1 304 Not Modified\r\n" : "Status: 304 Not Modified\r\n");
  return;
  }
 
 if (!strcmp(request, "/runtime.678742345B8E282393A78F7E3E4433E00FABF9F2.js")) {
  uw_write_header(ctx, "Content-Type: text/javascript\r\n");
   uw_write_header(ctx, "Last-Modified: Thu, 01 Jan 1970 00:00:00 GMT\r\n");
   uw_write_header(ctx, "Cache-Control: max-age=31536000, public\r\n");
   uw_write(ctx, jslib);
   return;
   }
  
  
  if (!strcmp(request, "/app.D3266DF1E4FD3F3A65F1A80B9AF5FD22A3127A4D.js")) {
   uw_write_header(ctx, "Content-Type: text/javascript\r\n");
    uw_write_header(ctx, "Last-Modified: Thu, 01 Jan 1970 00:00:00 GMT\r\n");
    uw_write_header(ctx, "Cache-Control: max-age=31536000, public\r\n");
    uw_write(ctx, jsapp);
    return;
    }
   
 if (uw_serve_file(ctx, request, "Thu, 01 Jan 1970 00:00:00 GMT")) return;
 
 if (!strncmp(request, "/Io_rpc/main", 12) && (request[12] == 0 || request[12] == '/')) {
  request += 12;
  if (*request == '/') ++request;
  uw_write_header(ctx, "Content-type: text/html; charset=utf-8\r\n");
   uw_write_header(ctx, "Content-script-type: text/javascript\r\n");
    uw_write(ctx, uw_begin_html5);
   uw_mayReturnIndirectly(ctx);
   uw_set_script_header(ctx, "<script type=\"text/javascript\" src=\"/runtime.678742345B8E282393A78F7E3E4433E00FABF9F2.js\"></script>\n<script type=\"text/javascript\" src=\"/app.D3266DF1E4FD3F3A65F1A80B9AF5FD22A3127A4D.js\"></script>\n");
   uw_set_could_write_db(ctx, 1);
  uw_set_at_most_one_query(ctx, 0);
  uw_set_needs_push(ctx, 1);
  uw_set_needs_sig(ctx, 0);
  uw_login(ctx);
  {
   uw_unit arg0 = uw_Basis_unurlifyUnit(ctx, &request);
    __uwn_wrap_main_5(ctx, arg0, 0);
   uw_write(ctx, "</html>");
    return;
   }
   }
  
  if (!strncmp(request, "/Io_rpc/rows", 12) && (request[12] == 0 || request[12] == '/')) {
   request += 12;
   if (*request == '/') ++request;
   uw_write_header(ctx, "Content-type: text/html; charset=utf-8\r\n");
    uw_write(ctx, uw_begin_html5);
    uw_mayReturnIndirectly(ctx);
    uw_set_script_header(ctx, "");
    uw_set_could_write_db(ctx, 0);
   uw_set_at_most_one_query(ctx, 1);
   uw_set_needs_push(ctx, 0);
   uw_set_needs_sig(ctx, 0);
   uw_login(ctx);
   {
    uw_unit arg0 = uw_Basis_unurlifyUnit(ctx, &request);
     __uwn_wrap_rows_4(ctx, arg0, 0);
    uw_write(ctx, "</html>");
     return;
    }
    }
  
  if (!strncmp(request, "/Io_rpc/twice", 13) && (request[13] == 0 || request[13] == '/')) {
   request += 13;
   if (*request == '/') ++request;
   if (uw_hasPostBody(ctx)) {
    uw_Basis_postBody pb = uw_getPostBody(ctx);
     if (pb.data[0])
     request = uw_Basis_strcat(ctx, request, pb.data);
     }
    uw_write_header(ctx, "Content-type: text/plain\r\n");
     uw_set_could_write_db(ctx, 1);
   uw_set_at_most_one_query(ctx, 0);
   uw_set_needs_push(ctx, 1);
   uw_set_needs_sig(ctx, 0);
   uw_login(ctx);
   {
    uw_Basis_int arg0 = uw_Basis_unurlifyInt(ctx, &request);
     uw_io_request __uwr;
    uw_io_request_begin(ctx, &__uwr);
    {
    int __uwfk = setjmp(*uw_jmp_buf(ctx));
     if (__uwfk == 0) {
     uw_Basis_int it0 =
      __uwn_twice_1(ctx, arg0, 0);
      uw_io_request_end(ctx, &__uwr, 0);
      uw_write(ctx, uw_get_real_script(ctx));
      uw_write(ctx, "\n");
      uw_Basis_urlifyInt_w(ctx, it0);
       return;
      } else
     uw_io_request_end(ctx, &__uwr, __uwfk);
      }
    }
    }
  
  if (!strncmp(request, "/Io_rpc/boom", 12) && (request[12] == 0 || request[12] == '/')) {
   request += 12;
   if (*request == '/') ++request;
   if (uw_hasPostBody(ctx)) {
    uw_Basis_postBody pb = uw_getPostBody(ctx);
     if (pb.data[0])
     request = uw_Basis_strcat(ctx, request, pb.data);
     }
    uw_write_header(ctx, "Content-type: text/plain\r\n");
     uw_set_could_write_db(ctx, 1);
   uw_set_at_most_one_query(ctx, 0);
   uw_set_needs_push(ctx, 0);
   uw_set_needs_sig(ctx, 0);
   uw_login(ctx);
   {
    uw_Basis_int arg0 = uw_Basis_unurlifyInt(ctx, &request);
     uw_io_request __uwr;
    uw_io_request_begin(ctx, &__uwr);
    {
    int __uwfk = setjmp(*uw_jmp_buf(ctx));
     if (__uwfk == 0) {
     uw_Basis_int it0 =
      __uwn_boom_2(ctx, arg0, 0);
      uw_io_request_end(ctx, &__uwr, 0);
      uw_write(ctx, uw_get_real_script(ctx));
      uw_write(ctx, "\n");
      uw_Basis_urlifyInt_w(ctx, it0);
       return;
      } else
     uw_io_request_end(ctx, &__uwr, __uwfk);
      }
    }
    }
  
  if (!strncmp(request, "/Io_rpc/flaky", 13) && (request[13] == 0 || request[13] == '/')) {
   request += 13;
   if (*request == '/') ++request;
   if (uw_hasPostBody(ctx)) {
    uw_Basis_postBody pb = uw_getPostBody(ctx);
     if (pb.data[0])
     request = uw_Basis_strcat(ctx, request, pb.data);
     }
    uw_write_header(ctx, "Content-type: text/plain\r\n");
     uw_set_could_write_db(ctx, 1);
   uw_set_at_most_one_query(ctx, 0);
   uw_set_needs_push(ctx, 0);
   uw_set_needs_sig(ctx, 0);
   uw_login(ctx);
   {
    uw_Basis_int arg0 = uw_Basis_unurlifyInt(ctx, &request);
     uw_io_request __uwr;
    uw_io_request_begin(ctx, &__uwr);
    {
    int __uwfk = setjmp(*uw_jmp_buf(ctx));
     if (__uwfk == 0) {
     uw_Basis_int it0 =
      __uwn_flaky_3(ctx, arg0, 0);
      uw_io_request_end(ctx, &__uwr, 0);
      uw_write(ctx, uw_get_real_script(ctx));
      uw_write(ctx, "\n");
      uw_Basis_urlifyInt_w(ctx, it0);
       return;
      } else
     uw_io_request_end(ctx, &__uwr, __uwfk);
      }
    }
    }
 uw_clear_headers(ctx);
 uw_write_header(ctx, uw_supports_direct_status ? "HTTP/1.1 404 Not Found\r\n" : "Status: 404 Not Found\r\n");
 uw_write_header(ctx, "Content-type: text/plain\r\n");
 uw_write(ctx, "Not Found");
 }
 
 static void uw_expunger(uw_context ctx, uw_Basis_client cli) {
  }
 static void uw_initializer(uw_context ctx) {
 uw_begin_initializing(ctx);
  uw_end_initializing(ctx);
  }
 uw_app uw_application = {1,
                            60,
                               "/",
                                   uw_client_init,
                                                  uw_initializer,
                                                                 uw_expunger,
                                                                             
                           uw_db_init,
                                      uw_db_begin,
                                                  uw_db_commit,
                                                               uw_db_rollback,
                                                                              
                           uw_db_close,
                                       uw_handle,
                                                 uw_input_num,
                                                              uw_cookie_sig,
                                                                            
                           uw_check_url,
                                        uw_check_mime,
                                                      uw_check_requestHeader,
                                                                             
                           uw_check_responseHeader,
                                                   uw_check_envVar,
                                                                   
                           uw_check_meta,
                                         NULL,
                                              my_periodics,
                                                           "%c",
                                                                1,
                                                                  NULL,
                                                                       
                           uw_served_files,
                                           1};
 