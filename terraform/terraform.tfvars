################
# lambda + SQS #
################
runtime      = "python3.8"
app_name     = "the-palace"

# use `sqs-send` to add messages to a SQS queue, and `sqs-rec` to pull messages off the queue.
architecture = "sqs-send"