select rh.segment1 REQ_NUM, rh.org_id, rl.requisition_line_id,
rl.requisition_header_id, ph.segment1 RFQ_NUM, ph.org_id,
pl.po_header_id, pl.po_line_id,
to_char(pl.creation_date, 'DD-Mon-RRRR HH24:MI:SS') cre_date,
ph.type_lookup_code, ph.from_type_lookup_code
from apps.po_requisition_headers_all rh,apps.po_requisition_lines_all rl,
apps. po_headers_all ph,apps.po_lines_all pl
where rh.requisition_header_id = rl.requisition_header_id
  and rl.last_update_date =pl.creation_date
  and pl.po_header_id = ph.po_header_id
  and rl.on_rfq_flag = 'Y'
  AND rh.segment1 = 'xxxxx '
  and rh.org_id = 'xxxxx'
-- and ph.segment1 = '&RFQ_NUM'
order by requisition_line_id desc
