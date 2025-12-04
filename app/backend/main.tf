# -----------------------------------
# DynamoDB Table for Queue Counter
# -----------------------------------
resource "aws_dynamodb_table" "queue_counter" {
  name           = "QueueCounter"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  lifecycle {
    ignore_changes = [item] # Previne tentar recriar o item a cada aplicação
  }
}

# Item inicial para definir o contador como 0
resource "aws_dynamodb_table_item" "initial_counter" {
  table_name = aws_dynamodb_table.queue_counter.name
  hash_key   = aws_dynamodb_table.queue_counter.hash_key

  item = jsonencode({
    id           = { S = "global" } # chave primária
    currentCount = { N = "0" }      # Contagem inicial
  })
}