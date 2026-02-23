import '../events/event_models.dart';

const seededReasonCodes = <ReasonCode>[
  ReasonCode(
    code: 'WAIT_LOAD',
    groupName: 'STANDBY_DELAY',
    label: 'Waiting for load',
    active: true,
  ),
  ReasonCode(
    code: 'WAIT_DUMP',
    groupName: 'STANDBY_DELAY',
    label: 'Waiting at dump point',
    active: true,
  ),
  ReasonCode(
    code: 'MECH_MINOR',
    groupName: 'BREAKDOWN',
    label: 'Minor mechanical issue',
    active: true,
  ),
  ReasonCode(
    code: 'MECH_MAJOR',
    groupName: 'BREAKDOWN',
    label: 'Major mechanical issue',
    active: true,
  ),
  ReasonCode(
    code: 'OTHER',
    groupName: 'GENERIC',
    label: 'Other',
    active: true,
  ),
];
