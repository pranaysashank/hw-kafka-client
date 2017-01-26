{-# LANGUAGE DeriveDataTypeable #-}
module Kafka
( module Kafka
, module X

-- ReExport
, rdKafkaVersionStr
) where

import Control.Exception
import Data.Typeable

import Kafka.Internal.RdKafka
import Kafka.Internal.RdKafkaEnum

import Kafka.Types as X

-- | Used to override default kafka config properties for consumers and producers
newtype KafkaProps = KafkaProps [(String, String)] deriving (Show, Eq)
emptyKafkaProps :: KafkaProps
emptyKafkaProps = KafkaProps []

-- | Used to override default topic config properties for consumers and producers
newtype TopicProps = TopicProps [(String, String)] deriving (Show, Eq)
emptyTopicProps :: TopicProps
emptyTopicProps = TopicProps []



-- | Kafka configuration object
data KafkaConf = KafkaConf RdKafkaConfTPtr deriving (Show)

-- | Kafka topic configuration object
data TopicConf = TopicConf RdKafkaTopicConfTPtr

-- | Main pointer to Kafka object, which contains our brokers
data Kafka = Kafka { kafkaPtr :: RdKafkaTPtr, _kafkaConf :: KafkaConf} deriving (Show)

-- | Main pointer to Kafka topic, which is what we consume from or produce to
data KafkaTopic = KafkaTopic
    RdKafkaTopicTPtr
    Kafka -- Kept around to prevent garbage collection
    TopicConf

-- | Log levels for the RdKafkaLibrary used in 'setKafkaLogLevel'
data KafkaLogLevel =
  KafkaLogEmerg | KafkaLogAlert | KafkaLogCrit | KafkaLogErr | KafkaLogWarning |
  KafkaLogNotice | KafkaLogInfo | KafkaLogDebug

instance Enum KafkaLogLevel where
   toEnum 0 = KafkaLogEmerg
   toEnum 1 = KafkaLogAlert
   toEnum 2 = KafkaLogCrit
   toEnum 3 = KafkaLogErr
   toEnum 4 = KafkaLogWarning
   toEnum 5 = KafkaLogNotice
   toEnum 6 = KafkaLogInfo
   toEnum 7 = KafkaLogDebug
   toEnum _ = undefined

   fromEnum KafkaLogEmerg = 0
   fromEnum KafkaLogAlert = 1
   fromEnum KafkaLogCrit = 2
   fromEnum KafkaLogErr = 3
   fromEnum KafkaLogWarning = 4
   fromEnum KafkaLogNotice = 5
   fromEnum KafkaLogInfo = 6
   fromEnum KafkaLogDebug = 7

-- | Any Kafka errors
data KafkaError =
    KafkaError String
  | KafkaInvalidReturnValue
  | KafkaBadSpecification String
  | KafkaResponseError RdKafkaRespErrT
  | KafkaInvalidConfigurationValue String
  | KafkaUnknownConfigurationKey String
  | KakfaBadConfiguration
    deriving (Eq, Show, Typeable)

instance Exception KafkaError

-- | Sets library log level (noisiness) with respect to a kafka instance
setLogLevel :: Kafka -> KafkaLogLevel -> IO ()
setLogLevel (Kafka kptr _) level =
  rdKafkaSetLogLevel kptr (fromEnum level)
