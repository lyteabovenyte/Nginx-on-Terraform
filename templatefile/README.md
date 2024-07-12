##### terraform templatefile:
- in short, if the application hosted on your infrastructure depends on certain configuration file which are usually not part of the application repository, terraform templates help manage those dynamic ways.
- Inside a template, users can specify different resources such as virtual machines, IAM components, storage resources, or networking components and configure their relationships and properties. When executed using the Terraform CLI, these templates are translated into a set of actions that realize the described infrastructure on the targeted provider.
- Terraform Templates are a great way to further extend the flexibility provided by modules. Templates manage the configuration and data files, enabling granular control and making the module more flexible and reusable.
- Terraform templates combine a few features – templatefile function, string literals, and template files themselves.
###### Note: Before runtime, make sure that the template files are available on the disk.
- 