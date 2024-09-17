# Deploying-a-microservice-app-to-EKS-cluster-
Deploying a shopping Microservice app to EKS cluster



Explanation:
chown :$GROUP_NAME "$KUBECONFIG_FILE": Changes the group ownership of the file to devops-team.
chmod 640 "$KUBECONFIG_FILE": Sets the file permissions so that the owner has read and write permissions, the group has read permissions, and others have no permissions.

make it executable with chmod +x devopsgroup.sh, and then run it with ./devopsgroup.sh

appName: frontendservice
replicaCount: 2
appImage: gcr.io/google-samples/microservices-demo/frontend
appVersion: v0.8.0
containerPort: 8080
env:
  PORT: "8080"
  RECOMMENDATION_SERVICE_ADDR: "recommendationservice:8080"
  CURRENCY_SERVICE_ADDR: "currencyservice:7000"
  SHIPPING_SERVICE_ADDR: "shippingservice:50051"
  CHECKOUT_SERVICE_ADDR:  "checkoutservice:5050"
  AD_SERVICE_ADDR:    "adservice:9555"
  CART_SERVICE_ADDR:  "cartservice:7070"
  PRODUCT_CATALOG_SERVICE_ADDR: "productcatalogservice:3550"
servicePort : 80
serviceType: LoadBalancer














appName: paymentservice
replicaCount: 2
appImage: gcr.io/google-samples/microservices-demo/paymentservice
appVersion: v0.8.0
containerPort: 50051
env:
  PORT: "50051"
servicePort : 50051


apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.appName }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Values.appName }}
  template:
    metadata:
      labels:
        app: {{ .Values.appName }}
    spec:
      containers:
        - name: {{ .Values.appName }}
          image: "{{ .Values.appImage }}:{{ .Values.appVersion }}"
          ports:
            - containerPort: {{ .Values.containerPort }}
              protocol: TCP
          env:  #since we have a lot of environment variables to use, this RANGE would loop through all of them 
            {{- range $key, $value := .Values.env }}
            - name: {{ $key }}
              value: "{{ $value }}"
            {{- end }}
          livenessProbe:
            grpc:
              port: {{ .Values.containerPort }}
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            grpc:
              port: {{ .Values.containerPort }}
            initialDelaySeconds: 5
            periodSeconds: 5
          resources:
            requests:
              memory: "128Mi"
              cpu: "250m"
            limits:
              memory: "256Mi"
              cpu: "500m"


apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.appName }}
spec:
  type: {{ .Values.serviceType }}
  selector: 
    app: {{ .Values.appName }}
  ports:
    - port: {{ .Values.servicePort }}
      targetPort: {{ .Values.containerPort }}
      protocol: TCP



REDIS
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.appName }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Values.appName }}
  template:
    metadata:
      labels:
        app: {{ .Values.appName }}
    spec:
      containers:
      - name: {{ .Values.appName }}
        image: "{{ .Values.appImage }}:{{ .Values.appVersion }}"
        ports:
        - containerPort: {{ .Values.containerPort }}
        livenessProbe:
          initialDelaySeconds: 5
          tcpSocket:
            port: {{ .Values.containerPort }}
          periodSeconds: 5
        readinessProbe:
          initialDelaySeconds: 5
          tcpSocket:
            port: {{ .Values.containerPort }}
          periodSeconds: 5
        resources:
          requests: 
            cpu: 70m
            memory: 200Mi
          limits:
            cpu: 125m
            memory: 300Mi
        volumeMounts:
        - name:  {{ .Values.volumeName }}
          mountPath: /data
      volumes:
      - name:  {{ .Values.volumeName }}
        emptyDir: {}


apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.appName }}
spec:
  type: ClusterIP
  selector:
    app: {{ .Values.appName }}
  ports:
  - protocol: TCP
    port: {{ .Values.servicePort }}
    targetPort: {{ .Values.containerPort }}
