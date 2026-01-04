# Week 1: Terraform Basics & Hello World
## Complete Beginner's Guide

### 🎯 Learning Objectives
By the end of this week, you will:
- Understand what Infrastructure as Code (IaC) means
- Know basic Terraform syntax and concepts
- Successfully run your first Terraform configuration
- Set up LocalStack for local AWS development

---

## Day 1-2: Understanding Terraform Fundamentals

### What is Infrastructure as Code (IaC)?
Think of IaC like a recipe for cooking. Instead of manually creating servers, databases, and networks by clicking buttons in a web console, you write "recipes" (code files) that describe exactly what infrastructure you want. Terraform reads these recipes and creates everything automatically.

**Traditional Way (Manual):**
1. Log into AWS console
2. Click "Create S3 bucket"
3. Fill out forms
4. Click "Create"
5. Repeat for each resource...

**IaC Way (Automated):**
1. Write a text file describing what you want
2. Run `terraform apply`
3. Everything gets created automatically!

### Key Terraform Concepts

**1. Resources** - The "things" you want to create (like S3 buckets, servers)
**2. Providers** - The "where" (AWS, Azure, Google Cloud)
**3. Configuration Files** - The "recipes" (files ending in `.tf`)
**4. State** - Terraform's "memory" of what it created

### Your First Terraform File

Let's start with the simplest possible example:

```hcl
# This is a comment in Terraform
output "greeting" {
  value = "Hello, Terraform World!"
}
```

**What this does:**
- `output` tells Terraform to display a value
- `"greeting"` is the name of our output
- `value` is what gets displayed
- `"Hello, Terraform World!"` is our message

### 🧪 Hands-On Exercise: Day 1

1. **Navigate to the exercise:**
   ```bash
   cd beginner-week1/day1-hello
   ```

2. **Look at the code:**
   ```bash
   cat main.tf
   ```

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```
   **What happened?** Terraform downloaded the providers it needs.

4. **See what Terraform will do:**
   ```bash
   terraform plan
   ```
   **What happened?** Terraform shows you what it plans to create/change.

5. **Apply the configuration:**
   ```bash
   terraform apply
   ```
   Type `yes` when prompted.

6. **See the output:**
   ```bash
   terraform output
   ```

**🎉 Congratulations!** You just ran your first Terraform configuration!

### Understanding the Workflow

Terraform has a simple 3-step workflow:
1. **`terraform init`** - Download what Terraform needs
2. **`terraform plan`** - Show what will happen
3. **`terraform apply`** - Make it happen

### 📝 Day 1-2 Exercises

**Exercise 1:** Modify the greeting message
- Change "Hello, Terraform World!" to your own message
- Run `terraform apply` again
- Notice how Terraform updates the output

**Exercise 2:** Add more outputs
- Add a new output called `timestamp` with value `timestamp()`
- Add another output called `random_number` (look at the existing code for hints)

**Exercise 3:** Explore Terraform commands
```bash
terraform show      # Show current state
terraform output    # Show all outputs
terraform destroy   # Clean up (removes everything)
```

---

## Day 3-4: Introduction to LocalStack

### What is LocalStack?

LocalStack is like having a "fake AWS" running on your computer. Instead of creating real AWS resources (which cost money), LocalStack pretends to be AWS services locally.

**Benefits:**
- ✅ **Free** - No AWS charges
- ✅ **Fast** - No internet delays
- ✅ **Safe** - Can't accidentally create expensive resources
- ✅ **Offline** - Works without internet

### Setting Up LocalStack

**Step 1: Start LocalStack**
```bash
# From the main repository directory
docker-compose up -d
```

**Step 2: Verify it's running**
```bash
curl http://localhost:4566/_localstack/health
```

You should see a JSON response showing available services.

### Understanding AWS Provider Configuration

When using LocalStack, we need to tell Terraform to use our local "fake AWS" instead of real AWS:

```hcl
provider "aws" {
  access_key = "test"        # Fake credentials
  secret_key = "test"        # Fake credentials
  region     = "us-east-1"   # Any region works
  
  # Tell Terraform to use LocalStack instead of real AWS
  endpoints {
    s3 = "http://localhost:4566"
  }
}
```

**What each part means:**
- `access_key` & `secret_key` - Normally real AWS credentials, but LocalStack accepts "test"
- `region` - AWS regions (us-east-1, eu-west-1, etc.)
- `endpoints` - Tells Terraform where to find services (LocalStack instead of AWS)

### 🧪 Hands-On Exercise: Day 3-4

1. **Make sure LocalStack is running:**
   ```bash
   docker-compose ps
   # Should show localstack_main as "Up"
   ```

2. **Navigate to the S3 exercise:**
   ```bash
   cd beginner-week1/day5-s3
   ```

3. **Examine the configuration:**
   ```bash
   cat main.tf
   ```
   Notice the `provider "aws"` block and `resource "aws_s3_bucket"` block.

4. **Initialize and apply:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

5. **Verify the bucket was created in LocalStack:**
   ```bash
   aws --endpoint-url=http://localhost:4566 s3 ls
   ```

**🎉 Success!** You just created your first AWS resource using Terraform and LocalStack!

### 📝 Day 3-4 Exercises

**Exercise 1:** Create multiple buckets
- Modify the code to create 2 different S3 buckets
- Give them different names
- Apply and verify both exist

**Exercise 2:** Explore LocalStack
```bash
# List all S3 buckets
aws --endpoint-url=http://localhost:4566 s3 ls

# Create a file in a bucket
echo "Hello LocalStack" > test.txt
aws --endpoint-url=http://localhost:4566 s3 cp test.txt s3://your-bucket-name/
```

---

## Day 5-7: Understanding Resources and State

### What are Resources?

Resources are the "things" you want to create. Each resource has:
- **Type** - What kind of thing (aws_s3_bucket, aws_instance)
- **Name** - What you call it in your code
- **Arguments** - Configuration options

```hcl
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-name"
}
```

**Breaking it down:**
- `resource` - Keyword telling Terraform this is a resource
- `"aws_s3_bucket"` - The type (S3 bucket from AWS provider)
- `"my_bucket"` - The name (what we call it in our code)
- `bucket = "..."` - Configuration (the actual bucket name in AWS)

### Understanding Terraform State

Terraform keeps track of what it created in a file called `terraform.tfstate`. This is Terraform's "memory."

**Important:** Never edit this file manually!

```bash
# See what Terraform knows about
terraform show

# List all resources Terraform manages
terraform state list
```

### Resource Dependencies

Sometimes resources depend on each other. Terraform figures this out automatically:

```hcl
resource "aws_s3_bucket" "data" {
  bucket = "my-data-bucket"
}

resource "aws_s3_bucket_object" "file" {
  bucket = aws_s3_bucket.data.bucket  # This depends on the bucket above
  key    = "myfile.txt"
  content = "Hello World"
}
```

### 🧪 Hands-On Exercise: Day 5-7

1. **Navigate to the multi-resource exercise:**
   ```bash
   cd beginner-week2/day1-multi-resource
   ```

2. **Study the configuration:**
   ```bash
   cat main.tf
   ```
   Notice how we create multiple different resources.

3. **Apply the configuration:**
   ```bash
   terraform init
   terraform plan    # Study the plan carefully
   terraform apply
   ```

4. **Explore what was created:**
   ```bash
   # List S3 buckets
   aws --endpoint-url=http://localhost:4566 s3 ls
   
   # List DynamoDB tables
   aws --endpoint-url=http://localhost:4566 dynamodb list-tables
   
   # List EC2 instances
   aws --endpoint-url=http://localhost:4566 ec2 describe-instances
   ```

5. **Examine Terraform's state:**
   ```bash
   terraform state list
   terraform show
   ```

### 📝 Day 5-7 Exercises

**Exercise 1:** Add a new resource
- Add an additional S3 bucket to the configuration
- Apply the changes
- Notice how Terraform only creates the new bucket

**Exercise 2:** Modify existing resources
- Change the DynamoDB table name
- Run `terraform plan` - what does Terraform want to do?
- Apply the changes

**Exercise 3:** Understand dependencies
- Look at the `random_id` resource
- See how it's used in the S3 bucket name
- This creates a dependency - Terraform must create the random_id first

---

## 🎯 Week 1 Summary

### What You've Learned
- ✅ Infrastructure as Code concepts
- ✅ Basic Terraform syntax and workflow
- ✅ LocalStack setup and usage
- ✅ Creating AWS resources with Terraform
- ✅ Understanding Terraform state
- ✅ Resource dependencies

### Key Commands You Know
```bash
terraform init      # Initialize project
terraform plan      # Preview changes
terraform apply     # Apply changes
terraform show      # Show current state
terraform destroy   # Clean up everything
```

### Next Steps
You're ready for **Week 2: Multiple Resources & Dependencies** where you'll learn to build more complex infrastructure and understand how resources work together.

---

## 🆘 Troubleshooting

**LocalStack won't start:**
```bash
docker-compose down
docker-compose up -d
docker-compose logs localstack
```

**Terraform errors:**
```bash
# Clear cache and reinitialize
rm -rf .terraform/
terraform init
```

**"Bucket already exists" error:**
- S3 bucket names must be globally unique
- Change the bucket name in your configuration
- Or run `terraform destroy` to clean up first

---

## 📚 Additional Reading

- [Terraform Documentation](https://terraform.io/docs)
- [LocalStack Documentation](https://docs.localstack.cloud)
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)

**Ready for Week 2?** Continue to [Week 2: Multiple Resources & Dependencies](../beginner-week2/README.md)
