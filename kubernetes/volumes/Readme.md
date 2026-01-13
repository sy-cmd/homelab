### Volumes
+ kubernetes volumes provide us a way to share data across containers or pods 
+ uses of volumes in k8s is to provide data persistence and for sharing across containers in the same pod or different pods 
+ volumes allow us to share data on our filesystem 

types of volumes 
Kubernetes supports several types of volumes.

PVC and PV
persistentVolume (PV) is the volume that is created by the admin of k8s, they can be NFS, cloud based storage,csi etc
persistenceVolumeClaim is a request for the storahe that was created by the admin and the pod or user requests for the volume

accessModes
these are the types of access we can mount on pods that request for PV
+ ReadWriteOnce (we can use read-write-once-pod) to insure that only one can can access the PV
+ ReadOnlyMany
+ ReadWriteMany
+ ReadWriteOncePod

persistentVolumeClaim(PVC) is the user or pod requesting for the volume 
+ most of the volumes that provided by cloud have deprecated 
 + awsElasticBlockStore (deprecated)
 + azureFile (deprecated)
 + cephfs (removed)

Provisioning
there are two ways of PV maybe provisioned
+ static -- this is when the admin creates the PV in the k8s cluster and they can be requested with PVC later requested or whenever needed
+ dynamic -- this is when they we don't create any PV and when pods try to request for PVC  that was not created the cluster tries to create the provision for them but they should be within the storage class. the admin should enable the defaultStorageClass through the *admission controller* on the api server

Reclaiming
when a pod or user is done with the the PV they and when the PVC  is deleted the PV can be deleted depending on the reclaim policy it has.
 + Retain -- with this policy the when PVC is deleted the PV still remains but is not ready to be used by other pods beacuse it stills has infrustrure from the other pod. we can delete it manually.
 + Delete -- plugins that supports this policy , when the PVC is the PV is deleted with it to
 + Recycle -- with this policy the PV is not deleted after PVC  has been deleted and its depresiated

PV when they are deleted tby the admin if they are in use by are user or pod in the cluster they are delayed  they don't get deleted immediately
configMap
+ it provides a way of injecting configuration  data into pods. 
+ the configmap can be referenced in the volume section
+ a configmap is alwasys configured as read only and a container using it as a subPath won't receive any updated when the configMap changes 

Storage Classes
+ a StorageClass provides a way for adminstartors to describe the storage they offer its similar to a profile that describes the storage systems in the cluster

StorageClass objects
+ the storage class containes the fields provisioner , parameters and reclaimPolicy which are used when a PVC PV need them

CSI drivers we can use in k8s
+ Longhorn
+ Rook-Ceph
+ OpenEBS Mayastor
+ Use native cloud CSI drivers

ISCSI
+ iSCSI (Internet Small Computer Systems Interface) is a protocol that allows Kubernetes to treat remote storage as if it were a local physical hard drive. It carries SCSI commands over a standard TCP/IP network.
+ we need to install it before we can use any csi driver on our cluster
downwardAPI
+ i have a script that installs ISCSI if its not installed 
+ A downwardAPI volume makes downward API data available to applications. Within the volume, you can find the exposed data as read-only files in plain text format.

emptyDir
+ for  pods that use empty directory the volume is assigned to them when they get to the nodes and when they are deleted the volume is deleted with them too 
Some uses for an emptyDir are:
+ scratch space, such as for a disk-based merge sort
+ checkpoint a long computation for recovery from crashes
+ holding files that a content-manager container fetches while a webserver container serves the data

hostPath
+ hostPath volumes mounts the volume from a nodes filesystem into a pods 
+ its better to use other types of volumes or pvc than host volumes as they come with a lot of risk ( such as when a done goes down the volume that was being accessed by pods it goes down too )

