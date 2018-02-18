#!/usr/bin/python
#-*- coding: utf-8 -*-
import web
import json, psycopg2

urls = (
    '/(api)/getslot', 'getSlot',
    '/(api)/show/(.*)', 'showSetup',
    '/(api)/createhardware', 'setHardware',
    '/(api)/manageswitch/(.*)', 'manageSwitch',
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

        try:
            self.cur.execute("Select dc.name, r.name, rw.name, ra.name, s.id, ra.id \
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
                                    inner join switchvlans sv on sv.hardware_id=h.id \
                                    where \
                                        np.incoming = 'true' \
                                        and np.id not in (\
                                            Select incoming from networkportconnection) \
                                        and sv.vlan_id = %s\
                                ) \
                                and dc.name = %s \
                                and hardware_id = '-1' \
                            group by dc.name, r.name, rw.name, ra.name, s.id;", (data['vlan'],data['datacenter']))
        except:
            return json.dumps({'error': "Invalid Request"})

        if 'slots' in data.keys():
            try:
                number = int(data['slots'])
            except:
                return json.dumps({'error': "Slots not a number"})

            rackid = 0
            for i in self.cur.fetchall():
                if rackid == 0 or int(i[5]) != rackid:
                    count = 0
                    rackid = int(i[5])
                count += 1
                if count == number:
                    slot = i

        else:
            slot = self.cur.fetchone()

        try:
            return json.dumps({'datacenter': slot[0], 'room': slot[1], 'row': slot[2], 'rack': slot[3], 'slot': slot[4]})
        except:
            return json.dumps({'error': 'No Slot found'})

class showSetup(Common):
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
            self.cur.execute("Insert into hardware (required_slots, typ, name) values (%s, %s, %s) returning id;", (data['slots'], data['typ'], data['hwname']))
            hwid = self.cur.fetchone()[0]
        except:
            return json.dumps({'error': "Not a valid Hardware"})

        try:
            sid = int(data['firstslot'])
            for i in range(data['slots']):
                self.cur.execute("Update slot set hardware_id = %s where rack_id = %s and id = %s;", (hwid, data['rackid'], sid))
                sid += 1
        except:
            return json.dumps({'error': "Not a rack layout"})

        portnumber = 0
        try:
            for i in data['networkport']:
                try:
                    self.cur.execute("insert into networkport (hardware_id, typ, portname) values (%s, %s, %s) returning id;", (hwid, i['typ'], "eth{0}".format(portnumber)))
                    nid = self.cur.fetchone()[0]
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

        self.pgcon.commit()
        return json.dumps({'success': 'Hardware {0} successful created'.format(data['hwname'])})

class manageSwitch(Common):
    def POST(self, api, method):
        try:
            data = json.loads(web.data())
        except:
            return json.dumps({'error': "Not valid JSON"})

        if method == "addVlan":
            try:
                self.cur.execute("insert into switchvlans (hardware_id, vlan_id) values (%s, %s);", (data['hardwareid'], data['vlan']))
                self.pgcon.commit()
            execpt:
                return json.dumps({'error': "Not able to add Vlan to {0}, faulty request or Vlan might already exist or hardware is not a switch".format(data['hardwareid'])})
            return json.dumps({'success': "Vlan added to {0}".format(data['hardwareid'])})
        elif method == "removeVlan":
            try:
                self.cur.execute("delete from switchvlans where hardware_id = %s and vlan_id = %s;", (data['hardwareid'], data['vlan']))
                self.pgcon.commit()
            execpt:
                return json.dumps({'error': "Not able to delete Vlan on {0}, faulty request or Vlan might be still in use".format(data['hardwareid'])})
            return json.dumps({'success': "Vlan reomved from {0}".format(data['hardwareid'])})
        elif method == "connect":
            try:
                self.cur.execute("insert into networkportconnection (incoming, outgoing) values (%s, %s);", (data['incoming'],data['outgoing']))
                self.pgcon.commit()
            except:
                return json.dumps({'error': "Not a valid connection, faulty request or Ports might still be in use."})
            return json.dumps({'success': "connected"})
        elif method == "disconnect":
            try:
                self.cur.execute("delete from networkportconnection where incoming = %s and outgoing = %s;", (data['incoming'],data['outgoing']))
                self.pgcon.commit()
            except:
                return json.dumps({'error': "Not a valid connection, faulty request or might already be disconnected."})
            return json.dumps({'success': "disconnected"})
        else:
            return json.dumps({'error': "Not command given"})


app = web.application(urls, globals())
if __name__ == "__main__":
    app.run()
