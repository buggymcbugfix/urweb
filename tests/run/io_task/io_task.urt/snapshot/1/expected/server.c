#include "include/urweb/config.h"
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
 #include <math.h>
 #include <time.h>
 #include "tests/run/io_task/iocheck.h"
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
  
 
  
  
  
  enum __uwe_result_s_1 { __uwc_Success_2, __uwc_Failure_3 };
   
   struct __uwd_result_s_1 {
   enum __uwe_result_s_1
   tag;
   union {
    uw_Basis_int uw_Success;
     uw_Basis_string uw_Failure;
    } data;
    };
  struct __uws_1 {
   uw_Basis_int __uwf_1;
    };
  struct __uws_2 {
   uw_Basis_int __uwf_N;
    };
  struct __uws_3 {
   struct __uws_2 __uwf_T;
    };
  /* SQL table uw_Io_task_t constraints   */
   
  
  
  static uw_unit
   __uwn_wrap_main_4(uw_context ctx, uw_unit __uwr_x0_0, uw_unit __uwr___1)
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
                                                                               PQexecPrepared(conn, "uw3", 0, paramValues, paramLengths, paramFormats, 0);
                                                                               
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
                                                                               uw_error(ctx, FATAL, "tests/run/io_task/io_task.ur:43:20-43:26: Query failed:\n%s\n%s", 
                                                                               "SELECT T_T.uw_N FROM uw_Io_task_t AS T_T ORDER BY T_T.uw_N", PQerrorMessage(conn));
                                                                               }
                                                                               
                                                                               if (PQnfields(res) != 1) {
                                                                               int nf = PQnfields(res);
                                                                               PQclear(res);
                                                                               uw_error(ctx, FATAL, "tests/run/io_task/io_task.ur:43:20-43:26: Query returned %d columns instead of 1:\n%s\n%s", nf, 
                                                                               "SELECT T_T.uw_N FROM uw_Io_task_t AS T_T ORDER BY T_T.uw_N", PQerrorMessage(conn));
                                                                               }
                                                                               
                                                                               uw_end_region(ctx);
                                                                               uw_push_cleanup(ctx, (void (*)(void *))PQclear, res);
                                                                               n = PQntuples(res);
                                                                               for (i = 0; i < n; ++i) {
                                                                               struct __uws_3 __uwr_r_2;
                                                                               uw_unit
                                                                               __uwr_acc_3
                                                                               =
                                                                               acc;
                                                                               
                                                                               __uwr_r_2.__uwf_T.__uwf_N
                                                                               =
                                                                               (PQgetisnull(res, i, 0) ? 
                                                                               ({uw_Basis_int
                                                                               tmp;
                                                                               uw_error(ctx, FATAL, "tests/run/io_task/io_task.ur:43:20-43:26: Unexpectedly NULL field #0");
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
 
 static int uw_input_num(const char *name) {
 return -1;}
 
 static void uw_periodic0(uw_context ctx) {
  uw_unit __uwr_$x_0 = 0, __uwr_$y_1 = 0;
   ({
    uw_Basis_int __uwr_n_2 =
    (uw_begin_region(ctx), uw_Iocheck_step(ctx));
    uw_end_region(ctx);
     ({
      uw_Basis_bool disc =
      __uwr_n_2 == 1LL;
      
      disc == uw_Basis_True ?
       ({
        uw_unit __uwr___3 =
        (uw_begin_region(ctx), uw_Basis_debug(ctx,
                                ({
                                 uw_Basis_string arg0 =
                                  "transaction open around io code: ";
                                  
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
                                          (uw_begin_region(ctx), ({
                                           
                                            
                                            uw_ensure_transaction(ctx);
                                            
                                            PGconn *conn = uw_get_db(ctx);
                                             static const int paramFormats[] = {  };
                                              const int *paramLengths = paramFormats;
                                               const char **paramValues = uw_malloc(ctx, 0 * sizeof(char*));
                                              
                                              
                                             PGresult *res;
                                             
                                             res = PQexecPrepared(conn, "uw0", 0, paramValues, paramLengths, paramFormats, 0);
                                             
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
                                                uw_error(ctx, FATAL, "tests/run/io_task/io_task.ur:15:29-17:42: DML failed:\n%s\n%s", 
                                                "INSERT INTO uw_Io_task_t (uw_N) VALUES (1::int8)", PQerrorMessage(conn));
                                               }
                                                 
                                                 PQclear(res);
                                                 
                                           
                                           uw_end_region(ctx);
                                           0;
                                           }));
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
              struct __uwd_result_s_1* __uwr_f_6 =
              ({
               uw_Basis_int* disc =
               ({
                uw_io_transaction __uwt;
                uw_Basis_int
                *__uwr = NULL;
                uw_io_transaction_begin(ctx, &__uwt);
                while (1) {
                int __uwfk = setjmp(*uw_jmp_buf(ctx));
                 if (__uwfk == 0) {
                 uw_Basis_int __uwv =
                  ({
                   uw_unit __uwr___6 =
                   (uw_begin_region(ctx), ({
                    
                     
                     uw_ensure_transaction(ctx);
                     
                     PGconn *conn = uw_get_db(ctx);
                      static const int paramFormats[] = {  };
                       const int *paramLengths = paramFormats;
                        const char **paramValues = uw_malloc(ctx, 0 * sizeof(char*));
                       
                       
                      PGresult *res;
                      
                      res = PQexecPrepared(conn, "uw1", 0, paramValues, paramLengths, paramFormats, 0);
                      
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
                         uw_error(ctx, FATAL, "tests/run/io_task/io_task.ur:20:32-22:40: DML failed:\n%s\n%s", 
                         "INSERT INTO uw_Io_task_t (uw_N) VALUES (2::int8)", PQerrorMessage(conn));
                        }
                          
                          PQclear(res);
                          
                    
                    uw_end_region(ctx);
                    0;
                    }));
                   ({
                    uw_unit __uwr___7 =
                    (uw_begin_region(ctx), ({
                                            uw_unit
                                            tmp;
                                            uw_error(ctx, FATAL, "tests/run/io_task/io_task.ur:21:32-22:40: %s", 
                                            "boom in a transaction");
                                            tmp;
                                            }));
                    uw_end_region(ctx);
                     0LL;
                    });
                   });
                  uw_io_transaction_commit(ctx, &__uwt);
                  __uwr = uw_malloc(ctx, sizeof(uw_Basis_int));
                  *__uwr = __uwv;
                  break;
                  } else if (!uw_io_transaction_retry(ctx, &__uwt, __uwfk)) {
                 __uwr = NULL;
                  break;
                  }
                 }
                uw_io_transaction_end(ctx, &__uwt, 0);
                __uwr;
                });
               
               disc != NULL && 1 ?
                ({uw_Basis_int __uwr_v_6 = (*disc);
                   ({
                    struct __uwd_result_s_1 *tmp =
                    uw_malloc(ctx, sizeof(struct __uwd_result_s_1));
                    tmp->tag =
                    __uwc_Success_2;
                    tmp->data.uw_Success = __uwr_v_6;
                     tmp;
                    });
                 })
                 :
                disc == NULL ?
                 ({
                  struct __uwd_result_s_1 *tmp =
                  uw_malloc(ctx, sizeof(struct __uwd_result_s_1));
                  tmp->tag =
                  __uwc_Failure_3;
                  tmp->data.uw_Failure =
                   uw_Basis_htmlifyString(ctx, uw_Basis_io_errorMessage(ctx));
                   tmp;
                  })
                  :
                 ({
                  struct __uwd_result_s_1*
                  tmp;
                  uw_error(ctx, FATAL, "tests/run/io_task/io_task.ur:20:8-35:30: pattern match failure");
                  tmp;
                  });
               });
              ({
               uw_unit __uwr___7 =
               (uw_begin_region(ctx), ({
                                       struct __uwd_result_s_1* disc =
                                       __uwr_f_6;
                                       
                                       disc->tag == __uwc_Failure_3 && 1 ?
                                        ({uw_Basis_string __uwr_m_7 =
                                           disc->data.uw_Failure;
                                           uw_Basis_debug(ctx,
                                            ({
                                             uw_Basis_string arg0 =
                                              "tryRunTransaction: Failure ";
                                              uw_Basis_string arg1 = __uwr_m_7;
                                               uw_Basis_strcat(ctx, arg0, arg1);
                                             }));
                                         })
                                         :
                                        disc->tag == __uwc_Success_2 && 1 ?
                                         ({uw_Basis_int __uwr_v_7 =
                                            disc->data.uw_Success;
                                            uw_Basis_debug(ctx,
                                             ({
                                              uw_Basis_string arg0 =
                                               "tryRunTransaction: Success ";
                                               
                                               uw_Basis_string arg1 =
                                                uw_Basis_intToString(ctx,
                                                 __uwr_v_7);
                                                uw_Basis_strcat(ctx, arg0, arg1);
                                              }));
                                          })
                                          :
                                         ({
                                          uw_unit
                                          tmp;
                                          uw_error(ctx, FATAL, "tests/run/io_task/io_task.ur:23:8-35:30: pattern match failure");
                                          tmp;
                                          });
                                       }));
               uw_end_region(ctx);
                ({
                 struct __uwd_result_s_1* __uwr_g_8 =
                 ({
                  uw_Basis_int* disc =
                  ({
                   uw_io_transaction __uwt;
                   uw_Basis_int
                   *__uwr = NULL;
                   uw_io_transaction_begin(ctx, &__uwt);
                   while (1) {
                   int __uwfk = setjmp(*uw_jmp_buf(ctx));
                    if (__uwfk == 0) {
                    uw_Basis_int __uwv =
                     ({
                      uw_unit __uwr___8 =
                      (uw_begin_region(ctx), uw_Iocheck_boundedRetry(ctx,
                                              "flaky"));
                      uw_end_region(ctx);
                       0LL;
                      });
                     uw_io_transaction_commit(ctx, &__uwt);
                     __uwr = uw_malloc(ctx, sizeof(uw_Basis_int));
                     *__uwr = __uwv;
                     break;
                     } else if (!uw_io_transaction_retry(ctx, &__uwt, __uwfk)) {
                    __uwr = NULL;
                     break;
                     }
                    }
                   uw_io_transaction_end(ctx, &__uwt, 0);
                   __uwr;
                   });
                  
                  disc != NULL && 1 ?
                   ({uw_Basis_int __uwr_v_8 = (*disc);
                      ({
                       struct __uwd_result_s_1 *tmp =
                       uw_malloc(ctx, sizeof(struct __uwd_result_s_1));
                       tmp->tag =
                       __uwc_Success_2;
                       tmp->data.uw_Success = __uwr_v_8;
                        tmp;
                       });
                    })
                    :
                   disc == NULL ?
                    ({
                     struct __uwd_result_s_1 *tmp =
                     uw_malloc(ctx, sizeof(struct __uwd_result_s_1));
                     tmp->tag =
                     __uwc_Failure_3;
                     tmp->data.uw_Failure =
                      uw_Basis_htmlifyString(ctx,
                       uw_Basis_io_errorMessage(ctx));
                      tmp;
                     })
                     :
                    ({
                     struct __uwd_result_s_1*
                     tmp;
                     uw_error(ctx, FATAL, "tests/run/io_task/io_task.ur:26:8-35:30: pattern match failure");
                     tmp;
                     });
                  });
                 ({
                  uw_unit __uwr___9 =
                  (uw_begin_region(ctx), ({
                                          struct __uwd_result_s_1* disc =
                                          __uwr_g_8;
                                          
                                          disc->tag == __uwc_Failure_3 && 1 ?
                                           ({uw_Basis_string __uwr_m_9 =
                                              disc->data.uw_Failure;
                                              uw_Basis_debug(ctx,
                                               ({
                                                uw_Basis_string arg0 =
                                                 "bounded retries: Failure ";
                                                 
                                                 uw_Basis_string arg1 =
                                                  __uwr_m_9;
                                                  uw_Basis_strcat(ctx, arg0, 
                                                                        arg1);
                                                }));
                                            })
                                            :
                                           disc->tag == __uwc_Success_2 && 1 ?
                                            ({uw_Basis_int __uwr_v_9 =
                                               disc->data.uw_Success;
                                               uw_Basis_debug(ctx,
                                                ({
                                                 uw_Basis_string arg0 =
                                                  "bounded retries: Success ";
                                                  
                                                  uw_Basis_string arg1 =
                                                   uw_Basis_intToString(ctx,
                                                    __uwr_v_9);
                                                   uw_Basis_strcat(ctx, arg0, 
                                                                         arg1);
                                                 }));
                                             })
                                             :
                                            ({
                                             uw_unit
                                             tmp;
                                             uw_error(ctx, FATAL, "tests/run/io_task/io_task.ur:27:8-35:30: pattern match failure");
                                             tmp;
                                             });
                                          }));
                  uw_end_region(ctx);
                   ({
                    uw_unit __uwr___10 =
                    (uw_begin_region(ctx), uw_Basis_debug(ctx,
                                            ({
                                             uw_Basis_string arg0 =
                                              "rows committed: ";
                                              
                                              uw_Basis_string arg1 =
                                               uw_Basis_intToString(ctx,
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
                                                    struct __uws_1* disc =
                                                    ({
                                                     struct __uws_1* acc =
                                                     NULL;
                                                     int dummy = (uw_begin_region(ctx), 0);
                                                     uw_ensure_transaction(ctx);
                                                     
                                                      
                                                      PGconn *conn = uw_get_db(ctx);
                                                       static const int paramFormats[] = {  };
                                                        const int *paramLengths = paramFormats;
                                                         const char **paramValues = uw_malloc(ctx, 0 * sizeof(char*));
                                                        
                                                        
                                                       PGresult *res = PQexecPrepared(conn, "uw2", 0, paramValues, paramLengths, paramFormats, 0);
                                                       
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
                                                         uw_error(ctx, FATAL, "$/top.ur:427:17-427:18: Query failed:\n%s\n%s", 
                                                         "SELECT COUNT(*) AS uw_1 FROM uw_Io_task_t AS T_T", PQerrorMessage(conn));
                                                         }
                                                        
                                                        if (PQnfields(res) != 1) {
                                                        int nf = PQnfields(res);
                                                         PQclear(res);
                                                         uw_error(ctx, FATAL, "$/top.ur:427:17-427:18: Query returned %d columns instead of 1:\n%s\n%s", nf, 
                                                         "SELECT COUNT(*) AS uw_1 FROM uw_Io_task_t AS T_T", PQerrorMessage(conn));
                                                         }
                                                        
                                                        uw_end_region(ctx);
                                                        uw_push_cleanup(ctx, (void (*)(void *))PQclear, res);
                                                        n = PQntuples(res);
                                                        for (i = 0; i < n; ++i) {
                                                        struct __uws_1 __uwr_r_10;
                                                         struct __uws_1*
                                                         __uwr_acc_11 =
                                                         acc;
                                                         
                                                         __uwr_r_10.__uwf_1 =
                                                          (PQgetisnull(res, i, 0) ? 
                                                           ({uw_Basis_int
                                                            tmp;
                                                            uw_error(ctx, FATAL, "$/top.ur:427:17-427:18: Unexpectedly NULL field #0");
                                                            tmp;
                                                            }) : uw_Basis_stringToInt_error(ctx, 
                                                                  PQgetvalue(res, i, 0)));
                                                          
                                                         
                                                         acc =
                                                         ({
                                                          struct __uws_1 *tmp =
                                                          uw_malloc(ctx, sizeof(
                                                          struct __uws_1));
                                                          *tmp =
                                                          __uwr_r_10;
                                                          tmp;
                                                          });
                                                         }
                                                        
                                                        uw_pop_cleanup(ctx);
                                                        
                                                     acc;
                                                     });
                                                    
                                                    disc == NULL ?
                                                     ({
                                                      uw_Basis_int
                                                      tmp;
                                                      uw_error(ctx, FATAL, "$/top.ur:428:24-429:3: %s", 
                                                      "Query returned no rows");
                                                      tmp;
                                                      })
                                                      :
                                                     disc != NULL && 1 ?
                                                      ({struct __uws_1
                                                         __uwr_r_10 = (*disc);
                                                         __uwr_r_10.__uwf_1;
                                                       })
                                                       :
                                                      ({
                                                       uw_Basis_int
                                                       tmp;
                                                       uw_error(ctx, FATAL, "tests/run/io_task/io_task.ur:30:16-30:68: pattern match failure");
                                                       tmp;
                                                       });
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
                      uw_unit __uwr___11 =
                      (uw_begin_region(ctx), uw_Basis_debug(ctx,
                                              ({
                                               uw_Basis_string arg0 = "env: ";
                                                
                                                uw_Basis_string arg1 =
                                                 ({
                                                  uw_Basis_string disc =
                                                  uw_Basis_getenv(ctx,
                                                   "IO_TASK_ENV");
                                                  
                                                  disc == NULL ? ""
                                                    :
                                                   disc != NULL && 1 ?
                                                    ({uw_Basis_string
                                                       __uwr_x_11 = disc;
                                                       __uwr_x_11;
                                                     })
                                                     :
                                                    ({
                                                     uw_Basis_string
                                                     tmp;
                                                     uw_error(ctx, FATAL, "tests/run/io_task/io_task.ur:33:28-33:34: pattern match failure");
                                                     tmp;
                                                     });
                                                  });
                                                 uw_Basis_strcat(ctx, arg0, 
                                                                       arg1);
                                               })));
                      uw_end_region(ctx);
                       ({
                        uw_unit __uwr___12 =
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
                                                   uw_unit
                                                   tmp;
                                                   uw_error(ctx, FATAL, "tests/run/io_task/io_task.ur:34:23-34:74: %s", 
                                                   "boom outside, via runTransaction");
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
                                                }));
                        uw_end_region(ctx);
                         uw_Basis_debug(ctx, "not reached");
                        });
                      });
                    });
                  });
                 });
               });
              });
            });
          });
        })
        :
       disc == uw_Basis_False ?
        ({
         uw_Basis_bool disc =
         __uwr_n_2 == 2LL;
         
         disc == uw_Basis_True ? uw_Basis_debug(ctx, "still running")
           :
          disc == uw_Basis_False ? 0
            :
           ({
            uw_unit
            tmp;
            uw_error(ctx, FATAL, "tests/run/io_task/io_task.ur:37:8-37:32: pattern match failure");
            tmp;
            });
         })
         :
        ({
         uw_unit
         tmp;
         uw_error(ctx, FATAL, "tests/run/io_task/io_task.ur:11:4-39:17: pattern match failure");
         tmp;
         });
      });
    });
   }
  
  static uw_periodic my_periodics[] = {{uw_periodic0, 1, 1},{NULL}};
 
 static int uw_check_url(const char *s) {
  if (!strncmp(s, "#", 1)) return 1;
   if (!strcmp(s, "/Io_task/main")) return 1;
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
  if (!strcmp(s, "IO_TASK_ENV")) return 1;
   return 0;
   }
  
 static int uw_check_meta(const char *s) {
  return 0;
   }
  
 extern void uw_sign(const char *in, char *out);
 extern int uw_hash_blocksize;
 static uw_Basis_string uw_cookie_sig(uw_context ctx) {
 uw_Basis_string r = uw_malloc(ctx, uw_hash_blocksize);
  uw_sign(uw_unnull(uw_Basis_getenv(ctx, "IO_TASK_ENV")), r);
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
 
 
 if (uw_serve_file(ctx, request, "Thu, 01 Jan 1970 00:00:00 GMT")) return;
 
 if (!strncmp(request, "/Io_task/main", 13) && (request[13] == 0 || request[13] == '/')) {
  request += 13;
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
    __uwn_wrap_main_4(ctx, arg0, 0);
   uw_write(ctx, "</html>");
    return;
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
                                           0};
 