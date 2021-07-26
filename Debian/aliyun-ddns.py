#!/usr/bin/env python3
#coding=utf-8

from json import encoder
import socket

import json

import aliyunsdkcore
from aliyunsdkcore.client import AcsClient
from aliyunsdkcore.acs_exception.exceptions import ClientException
from aliyunsdkcore.acs_exception.exceptions import ServerException
from aliyunsdkalidns.request.v20150109.DescribeDomainRecordsRequest import DescribeDomainRecordsRequest
from aliyunsdkalidns.request.v20150109.AddDomainRecordRequest import AddDomainRecordRequest
from aliyunsdkalidns.request.v20150109.UpdateDomainRecordRequest import UpdateDomainRecordRequest

ddns_name = "sh1-1"
ddns_type = "A"
intel_ip = (
    (
        [ip for ip in socket.gethostbyname_ex(socket.gethostname())[2] if (not ip.startswith("127.") and not ip.startswith("192.168"))] or
        [[(s.connect(("8.8.8.8", 53)), s.getsockname()[0], s.close()) for s in [socket.socket(socket.AF_INET, socket.SOCK_DGRAM)]][0][1]]
    ) + ["no IP found"]
)[0]

if "no IP found" in intel_ip:
    raise Exception("no IP found")

alikey = json.load(open("/etc/alikey.json","r",encoding="utf-8"))

client = AcsClient(alikey["accessKeyId"], alikey["accessSecret"], 'cn-hangzhou')

request = DescribeDomainRecordsRequest()
request.set_accept_format('json')
request.set_DomainName("askr.cc")
response = client.do_action_with_exception(request)
response=json.loads(str(response, encoding='utf-8'))
DomainRecords = response["DomainRecords"]["Record"]
hasSH1_1 = ddns_name in [_["RR"] for _ in DomainRecords]
if hasSH1_1:
    DomainRecords=[_ for _ in DomainRecords if _["RR"] == ddns_name][0]
    if DomainRecords["Value"] == intel_ip:
        print("Domain name resolution is normal")
    else:
        print("Domain name resolution needs to be updated")
        DomainRecords["RecordId"]
        request = UpdateDomainRecordRequest()
        request.set_accept_format('json')
        request.set_RecordId(DomainRecords["RecordId"])
        request.set_RR(ddns_name)
        request.set_Type(ddns_type)
        request.set_Value(intel_ip)
        response = client.do_action_with_exception(request)
        print("Domain name resolution update completed, New IP is ",intel_ip)
else:
    print("Domain name resolution does not exist, it needs to be added")
    request = AddDomainRecordRequest()
    request.set_accept_format('json')
    request.set_DomainName("askr.cc")
    request.set_RR(ddns_name)
    request.set_Type(ddns_type)
    request.set_Value(intel_ip)
    response = client.do_action_with_exception(request)
    print("Domain name resolution added, New IP is ",intel_ip)
