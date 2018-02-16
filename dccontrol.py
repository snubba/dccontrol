#!/usr/bin/python
#-*- coding: utf-8 -*-
import web
import json, psycopg2

urls = (
    '/(api)/getslot', 'getSlot',
    '/show/(.*)', 'showSetup',
    '/(api)/show/(.*)', 'showSetup',
    '/(api)/createhardware', 'setHardware',
)

class Common:
    def __init__(self):
        self.pgcon = psycopg2.connect("dbname=dccontrol user=dccontrol password=dccontrol")
        self.cur = self.pgcon.cursor()

class getSlot(Common):
    def POST(self, api):
        try:
            data = json.loads(web.data())
        except:
            return json.dumps({'error': "Not valid JSON"})

        if data['slots']:
            number = int(data['slots'])
            raise NotImplemented
        else:
            try:
                self.sur.execute("Select dc.name, r.name, rw.name, ra.name, s.id \
                            from datacenter dc \
                            inner join rooms r on dc.id=r.dc_id \
                            inner join rows rw on rw.room_id=r.id \
                            inner join rack ra on rw.id=ra.row_id \
                            inner join slot s on ra.id=s.rack_id \
                                where \
                                s.rack_id in (\
                                    select s.rack_id from \
                                    slot s \
                                    inner join hardware h on h.id = s.hardware_id \
                                    inner join networkport np on h.id=np.hardware_id \
                                    inner join protvlan pv on pv.network_port=np.id \
                                    where \
                                        np.incoming = 'true' \
                                        and np.id not in (\
                                            Select incoming from networkportconnection) \
                                        and pv.vlan_id = %s\
                                ) \
                                and dc.name = %s \
                                and hardware_id = '-1' \
                            group by dc.name, r.name, rw.name, ra.name, s.id;", (data['vlan'],data['datacenter']))
                slot = self.cur.fetchone()
            except:
                return json.dumps({'error': "Invalid Request"})
    
        return json.dumps({'datacenter': slot[0], 'room': slot[1], 'row': slot[2], 'rack': slot[3], 'slot': slot[4]})

class showSetup(Common):
#    def GET(self):
#        self.cur.execute("Select id, name from datacenter;")
#        return 
    
    def GET(self, api, request):
        request = request.split('/')
        return json.dumps(self.returnBundle(request))
            

    def parseSQL(self, fetch, hw=False):
        ret = []
        for i in fetch:
            line = {'name' : i[0]}
            idstr = 'id'
            if hw:
                line['hardwareid'] = i[3]
                idstr = 'slot'
            line[idstr] = i[1]
            ret.append(line)

        return ret

    def returnBundle(self, request):
        if len(request) == 1:
            try:
                self.cur.execute("Select name, id from rooms where dc_id = %s;", (request[0],))
                return {'rooms': self.parseSQL(self.cur.fetchall()), 'datacenterid': request[0]}
            except:
                pass
        elif len(request) == 2:
            try:
                self.cur.execute("Select name, id from rows where room_id = %s;", (request[1],))
                return {'rows': self.parseSQL(self.cur.fetchall()), 'roomid': request[1], 'datacenterid': request[0]}
            except:
                pass
        elif len(request) == 3:
            try:
                self.cur.execute("Select name, id from rack where row_id = %s;", (request[2],))
                return {'racks': self.parseSQL(self.cur.fetchall()), 'rowid': request[2], 'roomid': request[1], 'datacenterid': request[0]}
            except:
                pass
        elif len(request) == 4:
            try:
                self.cur.execute("select hw.name, s.id from slot s inner join hardware hw on hw.id=s.hardware_id where rack_id = %s;", (request[3],))
                return {'slots': self.parseSQL(self.cur.fetchall()), 'rackid': request[3], 'rowid': request[2], 'roomid': request[1], 'datacenterid': request[0]}
            except:
                pass
        
        return {'error': "Not a valid Request"}

class setHardware(Common):
    def POST(self, api):
        try:
            data = json.loads(web.data())
        except:
            return json.dumps({'error': "Not valid JSON"})

        try:
            hwid = self.cur.execute("Insert into hardware (required_slots, typ, name) values (%s, %s, %s) returning id;", (data['slots'], data['typ'], data['hwname']))
        except:
            return json.dumps({'error': "Not a valid Hardware"})

        try:
            sid = int(data['firstslot'])
            for i in range(data['slots']):
                self.cur.execute("Update slots set hardware_id = %s where rack_id = %s and id = %s;", (hwid, data['rackid'], sid))
                sid += 1
        except:
            return json.dumps({'error': "Not a rack layout"})

        portnumber = 0
        try:
            for i in data['networkport']:
                try:
                    nid = self.cur.execute("insert into networkport (hardware_id, typ, portname) values (%s, %s, %s);", (hwid, i['typ'], "eth{0}".format(portnumber)))
                    portnumber += 1
                    if 'connection' in i.keys():
                        try:
                            self.cur.execute("insert into networkportconnection (incoming, outgoing) values (%s, %s);", (i['connection'], nid))
                        except:
                            return json.dumps({'error': "eth{0} not a valid connection"})
                except:
                    return json.dumps({'error': "eth{0} not a valid network typ"})
        except:
            return json.dumps({'error': "not a valid network card"})
                
        return json.dump({'success': 'Hardware {0} successful created'.format(data['hwname'])})

app = web.application(urls, globals())
if __name__ == "__main__":
    app.run()
