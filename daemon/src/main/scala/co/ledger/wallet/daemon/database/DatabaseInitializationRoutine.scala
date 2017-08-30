package co.ledger.wallet.daemon.database

import javax.inject.{Inject, Singleton}

import co.ledger.wallet.daemon.Server
import co.ledger.wallet.daemon.services.{DatabaseService, ECDSAService, UsersService}
import co.ledger.wallet.daemon.utils.HexUtils
import org.bitcoinj.core.Sha256Hash
import org.spongycastle.util.encoders.Base64

import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.{Await, Future}
import scala.concurrent.duration._
import scala.util.Try

@Singleton
class DatabaseInitializationRoutine @Inject()(usersService: UsersService, ecdsa: ECDSAService) {
  import Server.profile.api._

  def perform(): Future[Unit] = {
    insertDemoUsers()
  }

  private def insertDemoUsers() = Future {
    if (Server.configuration.hasPath("demo_users")) {
      val usersConfig = Server.configuration.getConfigList("demo_users")
      for (i <- 0 until usersConfig.size()) {
        val userConfig = usersConfig.get(i)
        val username = userConfig.getString("username")
        val password = userConfig.getString("password")
        val auth = s"Basic ${Base64.toBase64String(s"$username:$password".getBytes)}"
        val privKey = Sha256Hash.hash(auth.getBytes)
        val pk = HexUtils.valueOf(Await.result(ecdsa.computePublicKey(privKey), Duration.Inf))
        Try(Await.result(usersService.insertUser(pk), Duration.Inf))
      }
    }
    ()
  }

}
