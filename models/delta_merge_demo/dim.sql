select 
snap.sdts, 
dmb.* 

from {{ ref('snap_v0')}} snap

inner join {{ ref('satx_merge_dmb')}} dmb
    on dmb.ldts <= snap.sdts

qualify
    row_number() over (partition by snap.sdts, dmb.hk1 order by ldts desc) = 1
    and cdc_operation != 'D'
